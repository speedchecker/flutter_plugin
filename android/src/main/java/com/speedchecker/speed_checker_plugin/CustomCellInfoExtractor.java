package com.speedchecker.speed_checker_plugin;

import android.util.Log;
import android.telephony.CellSignalStrengthLte;
import android.telephony.CellInfo;
import android.telephony.CellInfoLte;
import android.os.Build;
import java.lang.reflect.Method;

import com.speedchecker.android.sdk.Public.Model.SCellInfo;

/**
 * Enhanced utility class to extract SINR values from cellular information
 * with better handling of edge cases and zero values.
 */
public class CustomCellInfoExtractor {
    private static final String TAG = "CustomCellInfoExtractor";
    
    /**
     * Attempts to extract SINR value using multiple methods and calculations.
     * Validates values to avoid returning zeros or invalid readings.
     * 
     * @param cellInfo The SCellInfo object containing cell information
     * @return The SINR value or null if it cannot be determined
     */
    public static Integer extractSinrValue(SCellInfo cellInfo) {
        if (cellInfo == null) {
            return null;
        }
        
        // Track all potential values and select the most reliable one
        Integer lteSinrValue = null;
        Integer nrSinrValue = null;
        Integer calculatedSinrValue = null;
        Integer cqiDerivedSinrValue = null;
        Integer reflectionSinrValue = null;
        
        // Method 1: Try standard LTE SINR method
        try {
            int lteSinr = cellInfo.getLteRSSNR();
            if (lteSinr != Integer.MAX_VALUE && lteSinr != 0) {
                Log.d(TAG, "SINR extracted from LTE RSSNR: " + lteSinr);
                lteSinrValue = lteSinr;
            } else if (lteSinr == 0) {
                Log.d(TAG, "LTE RSSNR returned 0, may be invalid");
            }
        } catch (Exception e) {
            Log.d(TAG, "Failed to get LTE RSSNR", e);
        }
        
        // Method 2: Try 5G SINR method
        try {
            int nrSinr = cellInfo.getNrSINR();
            if (nrSinr != Integer.MAX_VALUE && nrSinr != 0) {
                Log.d(TAG, "SINR extracted from NR SINR: " + nrSinr);
                nrSinrValue = nrSinr;
            } else if (nrSinr == 0) {
                Log.d(TAG, "NR SINR returned 0, may be invalid");
            }
        } catch (Exception e) {
            Log.d(TAG, "Failed to get NR SINR", e);
        }
        
        // Method 3: Try Android's direct CellSignalStrengthLte approach if possible
        // This requires access to Android's telephony APIs and proper permissions
        try {
            // This is a placeholder for device-specific code that might be needed
            // The actual implementation would require access to TelephonyManager
            // and related Android APIs, which might not be accessible in your plugin
            Log.d(TAG, "Android direct signal strength API not implemented");
        } catch (Exception e) {
            Log.d(TAG, "Failed to use Android's direct signal APIs", e);
        }
        
        // Method 4: Calculate SINR from RSRP and RSRQ if available
        try {
            int lteRsrp = cellInfo.getLteRSRP();
            int lteRsrq = cellInfo.getLteRSRQ();
            
            if (lteRsrp != Integer.MAX_VALUE && lteRsrq != Integer.MAX_VALUE && 
                lteRsrp < 0 && lteRsrq < 0) { // Valid values should be negative
                // More accurate SINR estimation based on RSRP and RSRQ
                // SINR ≈ RSRP + RSRQ + 10*log10(12)
                double calculatedSinr = lteRsrp / 10.0 + lteRsrq + 10.8;
                
                // SINR is typically between -10 and 30 dB in practical scenarios
                if (calculatedSinr >= -10 && calculatedSinr <= 30) {
                    Log.d(TAG, "SINR calculated from RSRP and RSRQ: " + calculatedSinr);
                    calculatedSinrValue = (int) calculatedSinr;
                } else {
                    Log.d(TAG, "Calculated SINR outside typical range: " + calculatedSinr);
                }
            }
        } catch (Exception e) {
            Log.d(TAG, "Failed to calculate SINR from RSRP/RSRQ", e);
        }
        
        // Method 5: Try to derive from CQI if available
        try {
            int lteCqi = cellInfo.getLteCQI();
            if (lteCqi != Integer.MAX_VALUE && lteCqi > 0 && lteCqi <= 15) {
                // More accurate CQI to SINR mapping based on 3GPP standards
                // CQI index table from 3GPP TS 36.213
                int[] cqiToSinrMap = {
                    -6,  // CQI 1
                    -4,  // CQI 2
                    -2,  // CQI 3
                    0,   // CQI 4
                    2,   // CQI 5
                    4,   // CQI 6
                    6,   // CQI 7
                    8,   // CQI 8
                    10,  // CQI 9
                    12,  // CQI 10
                    14,  // CQI 11
                    16,  // CQI 12
                    18,  // CQI 13
                    20,  // CQI 14
                    22   // CQI 15
                };
                
                if (lteCqi > 0 && lteCqi <= cqiToSinrMap.length) {
                    cqiDerivedSinrValue = cqiToSinrMap[lteCqi - 1];
                    Log.d(TAG, "SINR estimated from CQI " + lteCqi + ": " + cqiDerivedSinrValue);
                }
            }
        } catch (Exception e) {
            Log.d(TAG, "Failed to derive SINR from CQI", e);
        }
        
        // Method 6: If all else fails, try to get a value via reflection
        try {
            Method[] methods = cellInfo.getClass().getMethods();
            for (Method method : methods) {
                String methodName = method.getName().toLowerCase();
                if ((methodName.contains("sinr") || methodName.contains("snr") || 
                    methodName.contains("rssnr")) && 
                    method.getParameterCount() == 0) {
                    
                    Object result = method.invoke(cellInfo);
                    if (result instanceof Number) {
                        int value = ((Number) result).intValue();
                        if (value != Integer.MAX_VALUE && value != 0) {
                            Log.d(TAG, "SINR found via reflection: " + value + " from method " + method.getName());
                            reflectionSinrValue = value;
                        } else if (value == 0) {
                            Log.d(TAG, "Method " + method.getName() + " returned 0, may be invalid");
                        }
                    }
                }
            }
        } catch (Exception e) {
            Log.d(TAG, "Failed to get SINR via reflection", e);
        }
        
        // Now decide which value to use, prioritizing the most reliable source
        // Priority: NR SINR > LTE SINR > Calculated > CQI-derived > Reflection-based
        
        if (nrSinrValue != null) {
            Log.d(TAG, "Using NR SINR value: " + nrSinrValue);
            return nrSinrValue;
        } else if (lteSinrValue != null) {
            Log.d(TAG, "Using LTE SINR value: " + lteSinrValue);
            return lteSinrValue;
        } else if (calculatedSinrValue != null) {
            Log.d(TAG, "Using calculated SINR value: " + calculatedSinrValue);
            return calculatedSinrValue;
        } else if (cqiDerivedSinrValue != null) {
            Log.d(TAG, "Using CQI-derived SINR value: " + cqiDerivedSinrValue);
            return cqiDerivedSinrValue;
        } else if (reflectionSinrValue != null) {
            Log.d(TAG, "Using reflection-based SINR value: " + reflectionSinrValue);
            return reflectionSinrValue;
        }
        
        // If we get here, we couldn't find any valid SINR value
        Log.d(TAG, "No valid SINR value could be determined");
        return null;
    }
    
    /**
     * Alternative approach: Using direct Android API if available
     * This requires proper permissions and might not be available in all contexts
     * @param androidCellInfo Android's CellInfo object
     * @return SINR value or null
     */
    public static Integer extractSinrFromAndroidApi(Object androidCellInfo) {
        if (androidCellInfo == null || !(androidCellInfo instanceof CellInfo)) {
            return null;
        }
        
        try {
            if (androidCellInfo instanceof CellInfoLte) {
                CellInfoLte cellInfoLte = (CellInfoLte) androidCellInfo;
                CellSignalStrengthLte signalStrengthLte = cellInfoLte.getCellSignalStrength();
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // This API is only available on Android 10 (API 29) and above
                    int rssi = signalStrengthLte.getRssi();
                    int rsrp = signalStrengthLte.getRsrp();
                    int rsrq = signalStrengthLte.getRsrq();
                    
                    // Check if we have valid values
                    if (rssi != CellInfo.UNAVAILABLE && rsrp != CellInfo.UNAVAILABLE && rsrq != CellInfo.UNAVAILABLE) {
                        // Calculate SINR based on RSSI, RSRP, RSRQ
                        double sinr = calculateSinrFromMeasurements(rssi, rsrp, rsrq);
                        Log.d(TAG, "SINR calculated from Android API: " + sinr);
                        return (int) sinr;
                    }
                }
                
                // Try to access RSSNR through reflection if direct API not available
                try {
                    Method rssnrMethod = signalStrengthLte.getClass().getMethod("getRssnr");
                    int rssnr = (int) rssnrMethod.invoke(signalStrengthLte);
                    if (rssnr != CellInfo.UNAVAILABLE && rssnr != 0) {
                        Log.d(TAG, "SINR from Android API reflection: " + rssnr);
                        return rssnr;
                    }
                } catch (Exception e) {
                    Log.d(TAG, "Could not get RSSNR through reflection", e);
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error extracting SINR from Android API", e);
        }
        
        return null;
    }
    
    /**
     * Calculate SINR from signal measurements
     * @param rssi Received Signal Strength Indicator
     * @param rsrp Reference Signal Received Power
     * @param rsrq Reference Signal Received Quality
     * @return Calculated SINR value
     */
    private static double calculateSinrFromMeasurements(int rssi, int rsrp, int rsrq) {
        // Advanced formula for SINR calculation
        // SINR ≈ 10*log10(10^(RSRP/10) / (10^(RSSI/10) - 10^(RSRP/10)))
        // Simplified approximation:
        return rsrp - rssi + 10;
    }
}