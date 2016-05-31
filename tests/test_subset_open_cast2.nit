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

# Tests if the RTA considers the dependencies of a cast to an open type.
#
# `alt1` and `alt2` check that the casts are not skipped when the bound is an
# enumerated type.

import core::kernel

class Foo
	super Int
	subset do return self % 42 == 0 #alt1,2# subset do return self % 41 == 0
end

class Bar[PT: Int]
	type VT: Int
	fun baz_pt: PT do return 42
	fun baz_vt: VT do return 42
end

class Qux[PT: Int]
	super Bar[PT]

	redef type VT: Foo
end

var bar: Bar[Int] = new Qux[Foo]
assert bar.baz_pt == 42 #alt2#
assert bar.baz_vt == 42
