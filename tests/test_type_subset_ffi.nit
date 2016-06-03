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

import core

class Natural #alt1# class Natural `{ long `}
	super Numeric
	subset do return self >= 0

	fun foo: String do return "bar"
	fun baz: String import Natural::foo `{ return Natural_foo(self); `}
end

redef class Natural #alt1# class Natural `{ long `}
	super Float

	redef fun foo: String do return "fu" + super
end

print(1.as(Natural).baz) #alt2# print(1.baz)
