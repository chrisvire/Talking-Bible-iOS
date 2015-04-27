//
//  Model+extensions.swift
//  TalkingBible
//
//  Created by Clay Smith on 11/19/14.
//  Copyright (c) 2014 Talking Bibles International. All rights reserved.
//

protocol ModelWithJSON {
    class func withJSON(json: JSONArray) -> [Self]
}