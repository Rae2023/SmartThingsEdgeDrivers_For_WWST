-- Copyright 2021 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local test = require "integration_test"
local capabilities = require "st.capabilities"
local zw = require "st.zwave"
local zw_test_utils = require "integration_test.zwave_test_utils"
local t_utils = require "integration_test.utils"

local button_endpoints = {
    {
        command_classes = {
            {value = zw.CENTRAL_SCENE},
            {value = zw.BATTERY}
        }
    }
}

local mock_fibaro_button = test.mock_device.build_test_zwave_device({
    profile = t_utils.get_profile_definition("button-generic.yml"),
    zwave_endpoints = button_endpoints,
    zwave_manufacturer_id = 0x010F,
    zwave_product_type = 0x0F01,
    zwave_product_id = 0x1000
})

local function  test_init()
    test.mock_device.add_test_device(mock_fibaro_button)
end
test.set_test_init_function(test_init)

test.register_message_test(
        "Fibaro button's supported button values",
        {
            {
                channel = "device_lifecycle",
                direction = "receive",
                message = { mock_fibaro_button.id, "added" }
            },
            {
                channel = "capability",
                direction = "send",
                message = mock_fibaro_button:generate_test_message("main",
                        capabilities.button.supportedButtonValues({"pushed", "held", "down_hold", "double", "pushed_3x", "pushed_4x", "pushed_5x"}))
            },
            {
                channel = "capability",
                direction = "send",
                message = mock_fibaro_button:generate_test_message("main", capabilities.button.numberOfButtons(
                  { value = 1 }
                ))
            }
        },
        {
            inner_block_ordering = "relaxed"
        }
)

test.run_registered_tests()
