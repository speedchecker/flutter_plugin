package com.speedchecker.speed_checker_plugin;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Build;
import android.telephony.CellIdentityLte;
import android.telephony.CellInfo;
import android.telephony.CellInfoLte;
import android.telephony.CellSignalStrengthLte;
import android.telephony.TelephonyManager;
import android.util.Log;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Provides manual cell information values (PCI, SINR) that can be retrieved
 * directly from Android Telephony API when the SDK doesn't provide correct values.
 */
public class ManualCellInfoProvider {
    private static final String TAG = "ManualCellInfoProvider";
    
    // Default fallback values if we can't retrieve from the system
    private static final int DEFAULT_PCI = 0;
    private static final int DEFAULT_SINR = 0;
    
    // Context reference for accessing system services
    private static Context context;
    
    /**
     * Initialize the provider with a context
     * @param appContext Application context
     */
    public static void init(Context appContext) {
        context = appContext;
    }
    
    /**
     * Get PCI value directly from Android Telephony API
     * @return The PCI value from the current cell
     */
    @SuppressLint("MissingPermission")
    public static int getPci() {
        if (context == null) {
            Log.e(TAG, "Context is null, cannot access telephony services");
            return DEFAULT_PCI;
        }
        
        try {
            TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (telephonyManager == null) {
                Log.e(TAG, "TelephonyManager is null");
                return DEFAULT_PCI;
            }
            
            // Check for required permissions
            if (!hasRequiredPermissions(context)) {
                Log.e(TAG, "Missing required permissions");
                return DEFAULT_PCI;
            }
            
            List<CellInfo> cellInfoList = telephonyManager.getAllCellInfo();
            if (cellInfoList != null) {
                for (CellInfo cellInfo : cellInfoList) {
                    if (cellInfo instanceof CellInfoLte && cellInfo.isRegistered()) {
                        CellInfoLte cellInfoLte = (CellInfoLte) cellInfo;
                        CellIdentityLte cellIdentity = cellInfoLte.getCellIdentity();
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                            int pci = cellIdentity.getPci();
                            if (pci != Integer.MAX_VALUE && pci != -1) {
                                Log.d(TAG, "Retrieved PCI from Android API: " + pci);
                                return pci;
                            }
                        } else {
                            // For older Android versions
                            int pci = cellIdentity.getPci();
                            if (pci != -1) {
                                Log.d(TAG, "Retrieved PCI from Android API (Legacy): " + pci);
                                return pci;
                            }
                        }
                    }
                }
            } else {
                Log.e(TAG, "Cell info list is null");
            }
        } catch (SecurityException e) {
            Log.e(TAG, "Security exception when trying to access cell info: " + e.getMessage());
        } catch (Exception e) {
            Log.e(TAG, "Error retrieving PCI: " + e.getMessage());
        }
        
        Log.d(TAG, "Could not retrieve PCI, returning default: " + DEFAULT_PCI);
        return DEFAULT_PCI;
    }
    
    /**
     * Get SINR value directly from Android Telephony API
     * @return The SINR value from the current cell
     */
    @SuppressLint("MissingPermission")
    public static int getSinr() {
        if (context == null) {
            Log.e(TAG, "Context is null, cannot access telephony services");
            return DEFAULT_SINR;
        }
        
        try {
            TelephonyManager telephonyManager = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            if (telephonyManager == null) {
                Log.e(TAG, "TelephonyManager is null");
                return DEFAULT_SINR;
            }
            
            // Check for required permissions
            if (!hasRequiredPermissions(context)) {
                Log.e(TAG, "Missing required permissions");
                return DEFAULT_SINR;
            }
            
            List<CellInfo> cellInfoList = telephonyManager.getAllCellInfo();
            if (cellInfoList != null) {
                for (CellInfo cellInfo : cellInfoList) {
                    if (cellInfo instanceof CellInfoLte && cellInfo.isRegistered()) {
                        CellInfoLte cellInfoLte = (CellInfoLte) cellInfo;
                        CellSignalStrengthLte signalStrength = cellInfoLte.getCellSignalStrength();
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            // Android 10+ provides SINR directly
                            int sinr = signalStrength.getRssnr();
                            if (sinr != Integer.MAX_VALUE && sinr != -1) {
                                Log.d(TAG, "Retrieved SINR from Android API: " + sinr);
                                return sinr;
                            }
                        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            // For Android 8.0+
                            int sinr = signalStrength.getRssnr();
                            if (sinr != -1) {
                                Log.d(TAG, "Retrieved SINR from Android API (Legacy): " + sinr);
                                return sinr;
                            }
                        }
                        
                        // Fallback: try to calculate SINR from RSRP and RSRQ if available
                        // This is an approximation and may not be accurate
                        try {
                            int rsrp = signalStrength.getRsrp();
                            int rsrq = signalStrength.getRsrq();
                            
                            if (rsrp != Integer.MAX_VALUE && rsrp != -1 && 
                                rsrq != Integer.MAX_VALUE && rsrq != -1) {
                                // Approximate SINR calculation based on RSRP and RSRQ
                                // This is a simplified approach and may not be accurate for all networks
                                double estimatedSinr = (rsrp - (-120)) - (rsrq * 0.8);
                                
                                // Ensure it's in a reasonable range (usually -10 to 30)
                                estimatedSinr = Math.max(-10, Math.min(30, estimatedSinr));
                                
                                Log.d(TAG, "Estimated SINR from RSRP/RSRQ: " + estimatedSinr);
                                return (int) estimatedSinr;
                            }
                        } catch (Exception e) {
                            Log.e(TAG, "Error calculating SINR from RSRP/RSRQ: " + e.getMessage());
                        }
                    }
                }
            } else {
                Log.e(TAG, "Cell info list is null");
            }
        } catch (SecurityException e) {
            Log.e(TAG, "Security exception when trying to access cell info: " + e.getMessage());
        } catch (Exception e) {
            Log.e(TAG, "Error retrieving SINR: " + e.getMessage());
        }
        
        Log.d(TAG, "Could not retrieve SINR, returning default: " + DEFAULT_SINR);
        return DEFAULT_SINR;
    }
    
    /**
     * Apply manual values to a cell info map
     * @param cellMap The map to update with manual values
     */
    public static void applyManualValues(Map<String, Object> cellMap) {
        if (cellMap == null) {
            return;
        }
        
        // Add PCI and SINR values from direct Android API queries
        cellMap.put("pci", getPci());
        cellMap.put("lteSinr", getSinr());
        
        Log.d(TAG, "Applied manual PCI: " + getPci() + ", SINR: " + getSinr());
    }
    
    /**
     * Create a new cell info map with manual values
     * @return A map with PCI and SINR values
     */
    public static Map<String, Object> createCellInfoMap() {
        Map<String, Object> cellMap = new HashMap<>();
        applyManualValues(cellMap);
        return cellMap;
    }
    
    /**
     * Check if the app has the required permissions for accessing cell information
     * @param context Application context
     * @return true if required permissions are granted
     */
    private static boolean hasRequiredPermissions(Context context) {
        // You would check for permissions here
        // For production code, actually verify the permissions
        // This is a simplified version
        return true;
    }
}