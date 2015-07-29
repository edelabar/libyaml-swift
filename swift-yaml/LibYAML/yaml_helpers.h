//
//  yaml_helpers.h
//  swift-yaml
//
//  Created by Niels de Hoog on 15/07/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

yaml_char_t* yaml_event_scalar_anchor(yaml_event_t *event);
yaml_char_t* yaml_event_scalar_tag(yaml_event_t *event);
yaml_char_t* yaml_event_scalar_value(yaml_event_t *event);
yaml_scalar_style_t yaml_event_scalar_style(yaml_event_t *event);

yaml_char_t* yaml_event_mapping_start_tag(yaml_event_t *event);
yaml_char_t* yaml_event_mapping_start_anchor(yaml_event_t *event);

yaml_char_t* yaml_event_sequence_start_anchor(yaml_event_t *event);

yaml_char_t* yaml_event_alias_anchor(yaml_event_t *event);


char* yaml_cstring_char(yaml_char_t *data);
char* yaml_cstring_uint8(uint8_t *data);
yaml_char_t* yaml_char_from_string(const unsigned char *string);
