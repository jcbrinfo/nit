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

class Natural
	super Int
	subset do return self >= 0
end

class Foo[BAR: Numeric]

	type BAZ: Numeric

	fun bar(x: Numeric): BAR do return x.as(BAR)
	fun baz(x: Numeric): BAZ do return x.as(BAZ)
	fun bar_baz(x: BAR, y: BAZ) do end
end

class Qux[BAR: Int]
	super Foo[BAR]

	#alt1,3,5# redef type BAZ: Natural
end

var qux = new Qux[Natural]

assert qux.bar(42) == 42
assert qux.baz(42) == 42
qux.bar_baz(42.as(Natural), 21.as(Natural))
#alt2# assert qux.bar(-1) == -1
#alt3# assert qux.baz(-1) == -1
#alt4# qux.bar_baz(-1, 21.as(Natural))
#alt5# qux.bar_baz(42.as(Natural), -1)
