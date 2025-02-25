//
//  Message.swift
//  ReadBuddyAi
//
//  Created by Deepanshu-Maliyan-Mac on 16/01/25.
//

import Foundation

struct Message {
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}
