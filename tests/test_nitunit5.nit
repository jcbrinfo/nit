# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module test_nitunit5 is test_suite

import test_suite

class TestNitunit5
	super TestSuite

	fun test_path_is_set do
		assert "NIT_TESTING_PATH".environ != ""
	end

	fun test_path_is_suite_path do
		assert "NIT_TESTING_PATH".environ.basename == "test_nitunit5.nit"
	end
end