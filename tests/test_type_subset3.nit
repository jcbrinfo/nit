# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import core::kernel

# TODO: alt1: An ordinary class that redefines the membership test.

class Foo
	super Object
	subset do return true

	#alt2# var bar: Int
	#alt3# init do end
	#alt4# fun set_x(x: Int) is autoinit do end
end

assert sys isa Foo
