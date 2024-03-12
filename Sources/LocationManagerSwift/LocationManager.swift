import Foundation
import CoreLocation

public struct Location {
    public var latitude: Double
    public var longitude: Double
}

public protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocations(_ manager: LocationManager, locations: [Location])
}

public class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager

    public weak var delegate: LocationManagerDelegate?

    public override init() {
        self.locationManager = CLLocationManager()
        super.init() // Ensure proper initialization of NSObject
    }

    public func start() {
        locationManager.delegate = self

        let status = locationManager.authorizationStatus
        handleLocationAuthorizationStatus(status)
    }

    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    private func setupLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    private func handleLocationAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            setupLocationManager()
            startUpdatingLocation()
            if status == .authorizedWhenInUse {
                locationManager.requestAlwaysAuthorization()
            }
        case .restricted, .denied:
            stopUpdatingLocation()
        @unknown default:
            break
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let convertedLocations = locations.map {
            Location(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
        }
        delegate?.didUpdateLocations(self, locations: convertedLocations)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleLocationAuthorizationStatus(manager.authorizationStatus)
    }
}
