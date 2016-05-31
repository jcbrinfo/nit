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

# Tests a cast to a subset where the base class of the subset is a superclass
# of a primitive type.
#
# This is a special case of the “autoboxing” mechanism that is cleared with
# non-subset classes by detecting useless casts.

import core::kernel

class Natural
	super Numeric
	subset do return self >= 0

	fun foo: Int do return 42
end

var x = 1
assert x isa Natural
assert x.foo == 42
# TODO: `assert x % 2 == 1` (alt1)
