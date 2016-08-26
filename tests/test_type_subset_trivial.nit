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

class Foo
	super Int
	subset
end

#alt1# class Foo
	#alt1# subset
#alt1# end

var foo: Foo
foo = 1.as(Foo) #alt2#
#alt2# foo = 0.5

assert foo + 1 == 2
assert foo isa Foo
assert foo isa Int
#alt3# assert foo isa nullable Foo