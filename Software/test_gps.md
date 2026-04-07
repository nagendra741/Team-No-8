# GPS Testing Guide

## How to Test GPS Location Issues

### 1. Enable Debug Mode
The app now includes comprehensive GPS debugging. To see debug output:

**For Android:**
```bash
flutter run --debug
# Then check the console output for GPS debug messages
```

**For Android with ADB logs:**
```bash
adb logcat | grep -i "flutter\|gps\|location"
```

### 2. Test GPS Functionality

1. **Open the Campus Companion app**
2. **Go to the Routing/Map page**
3. **Tap the GPS icon** (location button)
4. **Select "Test GPS"** from the options

This will run a comprehensive GPS test that:
- Checks location permissions
- Verifies GPS service is enabled
- Attempts to get location 3 times
- Shows accuracy, coordinates, and validation results
- Logs detailed debug information

### 3. Check Debug Output

Look for these debug messages in the console:

```
=== GPS DIAGNOSTICS START ===
Permission status: PermissionStatus.granted
Location service enabled: true
GPS Test attempt 1/3...
Attempt 1 - Success:
  Latitude: 9.57451
  Longitude: 77.67424
  Accuracy: 15.0m
  Distance from campus: 0m
  Location valid: true
=== GPS DIAGNOSTICS END ===
```

### 4. Common Issues and Solutions

#### Issue: "GPS accuracy too low"
- **Cause:** GPS accuracy > 100 meters
- **Solution:** Move to an open area, wait for better GPS signal

#### Issue: "GPS location seems incorrect"
- **Cause:** Location is more than 10km from campus
- **Solution:** Check if you're actually near the campus, or use manual location setting

#### Issue: "Location permission denied"
- **Cause:** App doesn't have location permission
- **Solution:** Grant location permission in device settings

#### Issue: "Location service disabled"
- **Cause:** GPS is turned off in device settings
- **Solution:** Enable GPS/Location services in device settings

### 5. Manual Location Setting

If GPS continues to fail:
1. Tap the GPS icon
2. Select "Set Manually"
3. Tap on your actual location on the map

### 6. Campus Center Fallback

The app uses these coordinates as campus center:
- **Latitude:** 9.57451
- **Longitude:** 77.67424
- **Location:** Near 1st Block, Kalasalingam University

### 7. Expected GPS Coordinates Range

Valid GPS coordinates for campus should be approximately:
- **Latitude:** 9.565 to 9.585
- **Longitude:** 77.665 to 77.690
- **Distance from campus center:** Less than 10km

If your GPS shows coordinates outside this range, the app will use campus center as fallback.
