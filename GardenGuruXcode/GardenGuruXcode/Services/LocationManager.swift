import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var locationCompletion: ((Result<CLLocation, Error>) -> Void)?
    
    // Add public method to check authorization status
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return manager.authorizationStatus
    }
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
        manager.pausesLocationUpdatesAutomatically = false
        
        // Clear any cached location data
        if CLLocationManager.locationServicesEnabled() {
            manager.stopUpdatingLocation()
            manager.startUpdatingLocation()
        }
        
        // Request permission immediately
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() async throws -> CLLocation {
        print("Requesting location...")
        
        // Check if location services are enabled
        guard CLLocationManager.locationServicesEnabled() else {
            print("Location services are disabled")
            throw NSError(domain: "Location services are disabled", code: -1)
        }
        
        // Check if Location Services are enabled in device settings
        if !CLLocationManager.locationServicesEnabled() {
            print("Location services are not enabled")
            throw NSError(domain: "Location services not enabled", code: -1)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationCompletion = { result in
                continuation.resume(with: result)
            }
            
            let status = manager.authorizationStatus
            print("Location auth status: \(status.rawValue)")
            
            switch status {
            case .notDetermined:
                print("Requesting authorization...")
                manager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                print("Location access denied")
                continuation.resume(throwing: NSError(domain: "Location Access Denied", code: -1))
            case .authorizedWhenInUse, .authorizedAlways:
                print("Starting location updates...")
                // Force a fresh location request
                manager.stopUpdatingLocation()
                manager.startUpdatingLocation()
            @unknown default:
                continuation.resume(throwing: NSError(domain: "Unknown Authorization Status", code: -2))
            }
        }
    }
    
    // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Got location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("Location accuracy: \(location.horizontalAccuracy) meters")
        print("Location timestamp: \(location.timestamp)")
        
        // Only accept recent locations with good accuracy
        let locationAge = -location.timestamp.timeIntervalSinceNow
        if location.horizontalAccuracy <= 100 && locationAge < 15 {
            manager.stopUpdatingLocation()
            locationCompletion?(.success(location))
        } else {
            print("Location rejected - Age: \(locationAge)s, Accuracy: \(location.horizontalAccuracy)m")
            // Continue looking for a better location
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                print("Location access denied by user")
            case .locationUnknown:
                print("Unable to determine location")
            default:
                print("Other location error: \(error.localizedDescription)")
            }
        }
        locationCompletion?(.failure(error))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization changed to: \(status.rawValue)")
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            locationCompletion?(.failure(NSError(domain: "Location Access Denied", code: -1)))
        default:
            break
        }
    }
} 
