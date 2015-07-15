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


char* yaml_cstring_char(yaml_char_t *data);