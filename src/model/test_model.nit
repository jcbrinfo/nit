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

# Some unit tests on `model`.
#
# Most of tests are actually done through `tests.sh`.
module test_model is test_suite

import test_suite
import model

class TestMType
	super TestSuite

	private var model: ModelDiamond is noinit

	private var mmodule: MModule is noinit

	private var object_type: MClassType is noinit

	private var type_a: MClassType is noinit

	private var type_b: MClassType is noinit

	private var type_c: MClassType is noinit

	private var type_d: MClassType is noinit

	init do
		model = new ModelDiamond
		mmodule = model.mmodule0
		object_type = model.mclass_o.mclass_type
		type_a = model.mclass_a.mclass_type
		type_b = model.mclass_b.mclass_type
		type_c = model.mclass_c.mclass_type
		type_d = model.mclass_d.mclass_type
	end

	fun test_is_subtype_nullable do
		var nullable_b = type_b.as_nullable
		var null_type = new MNullType(model)

		assert type_b.is_subtype(mmodule, null, nullable_b)
		assert not nullable_b.is_subtype(mmodule, null, type_b)
		assert null_type.is_subtype(mmodule, null, nullable_b)
		assert not nullable_b.is_subtype(mmodule, null, null_type)
	end

	fun test_is_subtype_intersection do
		var b_and_c = type_b.intersection(type_c, mmodule)
		var c_and_b = type_c.intersection(type_b, mmodule)

		# Are supertypes of D
		assert type_d.is_subtype(mmodule, null, b_and_c)
		assert type_d.is_subtype(mmodule, null, c_and_b)

		# Are sub-types of A
		assert b_and_c.is_subtype(mmodule, null, type_a)
		assert c_and_b.is_subtype(mmodule, null, type_a)
	end

	fun test_intersection_nullable_not_null do
		# Check that intersection with nullables are correctly computed in
		# order to make `is_subtype` work.

		var nullable_b = type_b.as_nullable
		var b_and_c = nullable_b.intersection(type_c, mmodule)
		var c_and_b = type_c.intersection(nullable_b, mmodule)
		var null_type = new MNullType(model)

		# Equivalence
		assert b_and_c == c_and_b

		# Are not null
		assert not b_and_c.can_be_null(mmodule)
		assert not c_and_b.can_be_null(mmodule)
		assert not null_type.is_subtype(mmodule, null, b_and_c)
		assert not null_type.is_subtype(mmodule, null, c_and_b)
		assert b_and_c.is_subtype(mmodule, null, object_type)
		assert c_and_b.is_subtype(mmodule, null, object_type)

		# Are supertypes of D
		assert type_d.is_subtype(mmodule, null, b_and_c)
		assert type_d.is_subtype(mmodule, null, c_and_b)
	end
end

class TestMIntersectionType
	super TestSuite

	private var model: ModelStandalone is noinit

	private var mmodule: MModule is noinit

	private var object_type: MClassType is noinit

	init do
		model = new ModelStandalone
		mmodule = model.mmodule0
		object_type = model.mclass_o.mclass_type
	end

	private fun assert_equals(actual, expected: Object) do
		assert actual == expected else
			print_error "{actual} == {expected}"
		end
	end

	fun test_as_notnull_formal do
		var type_s = new MTypeStub
		type_s.can_be_null_return = true
		type_s.need_anchor = true
		type_s.to_s = "S"

		var type_t = new MTypeStub
		type_t.can_be_null_return = true
		type_t.need_anchor = true
		type_t.to_s = "T"

		var s_and_t = type_s.intersection(type_t, mmodule)
		var actual = s_and_t.as_notnull
		var expected = new MIntersectionType.with_operands(
			mmodule,
			type_s,
			type_t,
			object_type
		)

		assert_equals(actual, expected)
	end

	fun test_c_name do
		var type_s = new MTypeStub
		type_s.c_name = "{mmodule.c_name}__S"
		var type_t = new MTypeStub
		type_t.c_name = "{mmodule.c_name}__T"
		var s_and_t = new MIntersectionType.with_operands(
			mmodule, type_s, type_t
		)
		assert_equals(
			s_and_t.c_name,
			"and2__{mmodule.c_name}__S__{mmodule.c_name}__T"
		)
	end

	fun test_c_name_notnull do
		var type_foo = new MTypeStub
		type_foo.c_name = "{mmodule.c_name}__MyClass__FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, type_foo
		)
		assert_equals(
			not_null_foo.full_name,
			"not_null__{mmodule.c_name}__MyClass__FOO"
		)
	end

	fun test_full_name do
		var type_s = new MTypeStub
		type_s.full_name = "{mmodule.full_name}::S"
		var type_t = new MTypeStub
		type_t.full_name = "{mmodule.full_name}::T"
		var s_and_t = new MIntersectionType.with_operands(
			mmodule, type_s, type_t
		)
		assert_equals(
			s_and_t.full_name,
			"({mmodule.full_name}::S and {mmodule.full_name}::T)"
		)
	end

	fun test_full_name_notnull do
		var type_foo = new MTypeStub
		type_foo.full_name = "{mmodule.full_name}::MyClass::FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, type_foo
		)
		assert_equals(
			not_null_foo.full_name,
			"not null {mmodule.full_name}::MyClass::FOO"
		)
	end

	fun test_to_s do
		var type_s = new MTypeStub
		type_s.to_s = "S"
		var type_t = new MTypeStub
		type_t.to_s = "T"
		var s_and_t = new MIntersectionType.with_operands(
			mmodule, type_s, type_t
		)
		assert_equals(s_and_t.to_s, "(S and T)")
	end

	fun test_to_s_notnull do
		var type_foo = new MTypeStub
		type_foo.to_s = "FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, type_foo
		)
		assert_equals(not_null_foo.to_s, "not null FOO")
	end
end

private class MTypeStub
	super MType

	redef var c_name is noinit
	var can_be_null_return: Bool = false is writable
	redef fun can_be_null(mmodule, anchor) do return can_be_null_return
	redef var depth is noinit
	redef var full_name is noinit
	redef var is_ok is noinit
	redef var length is noinit
	redef var need_anchor is noinit
	redef var to_s is noinit
end
