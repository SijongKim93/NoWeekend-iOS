//
//  LocationInfo.swift
//  Utils
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import Foundation
import CoreLocation

public struct LocationCoordinate: Equatable {
    public let latitude: Double
    public let longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from clLocation: CLLocation) {
        self.latitude = clLocation.coordinate.latitude
        self.longitude = clLocation.coordinate.longitude
    }
}

public struct LocationInfo: Equatable {
    public let coordinate: LocationCoordinate
    public let timestamp: Date
    
    public init(coordinate: LocationCoordinate, timestamp: Date = Date()) {
        self.coordinate = coordinate
        self.timestamp = timestamp
    }
    
    init(from clLocation: CLLocation) {
        self.coordinate = LocationCoordinate(from: clLocation)
        self.timestamp = clLocation.timestamp
    }
}

public enum LocationPermissionStatus: Equatable {
    case notDetermined
    case denied
    case restricted
    case authorizedWhenInUse
    case authorizedAlways
    
    init(from clStatus: CLAuthorizationStatus) {
        switch clStatus {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        case .authorizedWhenInUse:
            self = .authorizedWhenInUse
        case .authorizedAlways:
            self = .authorizedAlways
        @unknown default:
            self = .notDetermined
        }
    }
}
