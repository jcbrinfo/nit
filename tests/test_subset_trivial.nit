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

subset Foo
	super Int
	isa do return true
end

#alt1# subset Foo
#alt1# end

var foo: Foo
foo = 1.as(Foo)
#alt2# foo = 0.5
#alt3# foo = (0.5).as(Foo)

assert foo + 1 == 2
assert foo isa Foo
assert foo isa Int
#alt4# assert foo isa nullable Foo
