//
//  LocationManager.swift
//  Shared
//
//  Created by 김나희 on 7/13/25.
//  Copyright © 2025 com.noweekend. All rights reserved.
//

import CoreLocation
import Combine
import UIKit

public final class LocationManager: NSObject, ObservableObject {
    public static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published public var authorizationStatus: LocationPermissionStatus = .notDetermined
    @Published public var currentLocation: LocationInfo?
    @Published public var locationError: Error?
    
    // UserDefaults 키
    private let latitudeKey = "saved_latitude"
    private let longitudeKey = "saved_longitude"
    private let locationTimestampKey = "location_timestamp"
    
    public override init() {
        super.init()
        locationManager.delegate = self
        
        // 초기화 시 현재 권한 상태 설정
        authorizationStatus = LocationPermissionStatus(from: locationManager.authorizationStatus)
        
        // 저장된 위치 정보 불러오기
        loadSavedLocation()
    }
    
    // MARK: - Public Methods
    
    public func requestLocationPermission() {
        // 현재 권한 상태를 다시 확인
        let currentStatus = locationManager.authorizationStatus
        authorizationStatus = LocationPermissionStatus(from: currentStatus)
        
        print("권한 요청 - 현재 상태: \(currentStatus.rawValue)")
        
        switch currentStatus {
        case .notDetermined:
            print("권한 요청 팝업 표시")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("권한 거부됨")
            openAppSettings()
        case .authorizedWhenInUse, .authorizedAlways:
            print("권한 허용됨 - 저장된 위치 확인")
            // 권한이 있으면 저장된 위치 사용, 없으면 받기
            if getSavedLocation() == nil {
                print("저장된 위치 없음 - 위치 요청")
                requestLocation()
            } else {
                print("저장된 위치 있음 - 사용")
            }
        @unknown default:
            break
        }
    }
    
    public func requestLocationOnce() {
        guard hasLocationPermission else {
            print("위치 요청 실패 - 권한 없음")
            return
        }
        
        print("위치 요청")
        requestLocation()
    }
    
    // 사용자가 위치 버튼을 눌렀을 때 호출
    public func refreshLocation() {
        guard hasLocationPermission else {
            print("위치 새로고침 실패 - 권한 없음")
            return
        }
        
        print("위치 새로고침")
        requestLocation()
    }
    
    public func getSavedLocation() -> LocationInfo? {
        let defaults = UserDefaults.standard
        let latitude = defaults.double(forKey: latitudeKey)
        let longitude = defaults.double(forKey: longitudeKey)
        
        if latitude != 0 && longitude != 0 {
            let coordinate = LocationCoordinate(latitude: latitude, longitude: longitude)
            let timestamp = Date(timeIntervalSince1970: defaults.double(forKey: locationTimestampKey))
            return LocationInfo(coordinate: coordinate, timestamp: timestamp)
        }
        return nil
    }
    
    public func getDefaultLocation() -> LocationInfo {
        let coordinate = LocationCoordinate(latitude: 37.5665, longitude: 126.9780)
        return LocationInfo(coordinate: coordinate)
    }
    
    // MARK: - Private Methods
    
    private var hasLocationPermission: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    private func requestLocation() {
        locationManager.requestLocation()
    }
    
    private func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func loadSavedLocation() {
        if let savedLocation = getSavedLocation() {
            currentLocation = savedLocation
            print("저장된 위치 로드: \(savedLocation.coordinate)")
        } else {
            currentLocation = nil
            print("저장된 위치 없음")
        }
    }
    
    private func saveLocation(_ location: CLLocation) {
        let defaults = UserDefaults.standard
        defaults.set(location.coordinate.latitude, forKey: latitudeKey)
        defaults.set(location.coordinate.longitude, forKey: longitudeKey)
        defaults.set(Date().timeIntervalSince1970, forKey: locationTimestampKey)
        print("위치 저장 완료: \(location.coordinate)")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { 
            print("위치 업데이트 실패 - 위치 데이터 없음")
            return 
        }
        
        Task { @MainActor in
            self.currentLocation = LocationInfo(from: location)
            self.locationError = nil
            self.saveLocation(location)
            print("위치 업데이트: \(location.coordinate)")
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.locationError = error
            print("위치 오류: \(error.localizedDescription)")
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("권한 상태 변경: \(status.rawValue)")
        
        Task { @MainActor in
            self.authorizationStatus = LocationPermissionStatus(from: status)
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print("권한 허용됨 - 위치 요청 가능")
                break
            case .denied, .restricted:
                print("권한 거부됨")
                break
            case .notDetermined:
                print("권한 미결정")
                break
            @unknown default:
                break
            }
        }
    }
} 
