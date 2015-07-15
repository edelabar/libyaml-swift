//
//  yaml_helpers.c
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

#import "yaml.h"
#import "yaml_helpers.h"

yaml_char_t* yaml_event_scalar_anchor(yaml_event_t *event) {
    return event->data.scalar.anchor;
}

yaml_char_t* yaml_event_scalar_tag(yaml_event_t *event) {
    return event->data.scalar.tag;
}

yaml_char_t* yaml_event_scalar_value(yaml_event_t *event) {
    return event->data.scalar.value;
}

char* yaml_cstring_char(yaml_char_t *data) {
    return (char *)data;
}