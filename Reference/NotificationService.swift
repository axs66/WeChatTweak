//
//  NotificationService.swift
//  WeChatNotificationServiceExtension
//
//  Created by hbb on 2025/3/25.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
//        bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
        
        if shouldShowSubTitle() {
            bestAttemptContent.subtitle = "xxxxxx.com更多有趣插件"
        }
        let hbbSoundKey = "hbbSoundKey"
        let userInfo = request.content.userInfo
        if let apsDic = userInfo["aps"] as? [String: Any], let soundName = apsDic["sound"] as? String {
            
            let soundNameStr = soundName as NSString
            var newSoundName:String?
            let pathExtension = soundNameStr.pathExtension
            if pathExtension == "mp" {
                newSoundName = soundName + "3"
            } else if soundName == "building" {
                newSoundName = "buildingBlock.mp3"
            } else if pathExtension == "" {
                let fileName = soundName.trimmingCharacters(in: CharacterSet(charactersIn: "."))
                newSoundName = fileName + ".mp3"
            }
            
            if let newSoundName = newSoundName {
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: newSoundName))
            }
            
            if soundName != "call.caf" {
                if isSoundChanged(soundName) {
                    if let newSoundName = newSoundName {
                        bestAttemptContent.subtitle = "消息提示音已变更为\(newSoundName)"
                        UserDefaults.standard.set(newSoundName, forKey: hbbSoundKey)
                    } else {
                        bestAttemptContent.subtitle = "消息提示音已变更为\(soundName)"
                        UserDefaults.standard.set(soundName, forKey: hbbSoundKey)
                    }
                    UserDefaults.standard.synchronize()
                }
            }
        } else {
            if let hbbSound = UserDefaults.standard.string(forKey: hbbSoundKey) {
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: hbbSound))
            } else {
                bestAttemptContent.sound = UNNotificationSound.default
            }
        }
        
        contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    func shouldShowSubTitle() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let todayStr = formatter.string(from: Date())
        
        if let saveTodayStr = UserDefaults.standard.string(forKey: "todayDate") {
            if todayStr == saveTodayStr {
                return false
            }
        }
        
        UserDefaults.standard.set(todayStr, forKey: "todayDate")
        UserDefaults.standard.synchronize()
        
        return true
    }
    
    func isSoundChanged(_ soundName:String) -> Bool {
        
        if let saveSoundName = UserDefaults.standard.string(forKey: "soundName") {
            if saveSoundName == soundName {
                //铃声没有改变
                return false
            }
        }
        
        //文件改变了
        UserDefaults.standard.set(soundName, forKey: "soundName")
        UserDefaults.standard.synchronize()
        
        return true
    }

}
