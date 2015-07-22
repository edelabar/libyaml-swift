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

yaml_scalar_style_t yaml_event_scalar_style(yaml_event_t *event) {
    return event->data.scalar.style;
}

yaml_char_t* yaml_event_mapping_start_tag(yaml_event_t *event) {
    return event->data.mapping_start.tag;
}

yaml_char_t* yaml_event_mapping_start_anchor(yaml_event_t *event) {
    return event->data.mapping_start.anchor;
}

yaml_char_t* yaml_event_sequence_start_anchor(yaml_event_t *event) {
    return event->data.sequence_start.anchor;
}

yaml_char_t* yaml_event_alias_anchor(yaml_event_t *event) {
    return event->data.alias.anchor;
}

char* yaml_cstring_char(yaml_char_t *data) {
    return (char *)data;
}