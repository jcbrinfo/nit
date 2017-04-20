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

	private var model: Model is noinit

	private var mmodule: MModule is noinit

	private var object_type: MClassType is noinit

	private var a_type: MClassType is noinit

	private var b_type: MClassType is noinit

	private var d_type: MClassType is noinit

	init do
		mmodule = create_dummy_mmodule
		model = mmodule.model
		object_type = create_class("Object", interface_kind,
				new Array[MClassType])
		a_type = create_class("A", concrete_kind, [object_type])
		b_type = create_class("B", concrete_kind, [object_type])
		d_type = create_class("D", concrete_kind, [a_type, b_type])
	end

	private fun create_class(
		name: String, kind: MClassKind, supertypes: Array[MClassType]
	): MClassType do
		var location = new Location(null, 1, 1, 1, 1)
		var mclass = new MClass(mmodule, name, location, null, kind,
				public_visibility)
		var mtype = mclass.get_mtype(new Array[MClassType])
		var mclass_def = new MClassDef(mmodule, mtype, location)
		mclass_def.set_supertypes(supertypes)
		return mtype
	end

	fun test_is_subtype_nullable do
		var nullable_a = a_type.as_nullable
		var null_type = new MNullType(model)

		assert a_type.is_subtype(mmodule, null, nullable_a)
		assert not nullable_a.is_subtype(mmodule, null, a_type)
		assert null_type.is_subtype(mmodule, null, nullable_a)
		assert not nullable_a.is_subtype(mmodule, null, null_type)
	end

	fun test_is_subtype_intersection do
		var a_and_b = a_type.intersection(b_type, mmodule)
		var b_and_a = b_type.intersection(a_type, mmodule)

		# Are supertypes of D
		assert d_type.is_subtype(mmodule, null, a_and_b)
		assert d_type.is_subtype(mmodule, null, b_and_a)

		# Are sub-types of Object
		assert a_and_b.is_subtype(mmodule, null, object_type)
		assert b_and_a.is_subtype(mmodule, null, object_type)
	end

	fun test_intersection_nullable_not_null do
		# Check that intersection with nullables are correctly computed in
		# order to make `is_subtype` work.

		var nullable_a = a_type.as_nullable
		var a_and_b = nullable_a.intersection(b_type, mmodule)
		var b_and_a = b_type.intersection(nullable_a, mmodule)
		var null_type = new MNullType(model)

		# Equivalence
		assert a_and_b == b_and_a

		# Are not null
		assert not a_and_b.can_be_null(mmodule)
		assert not b_and_a.can_be_null(mmodule)
		assert not null_type.is_subtype(mmodule, null, a_and_b)
		assert not null_type.is_subtype(mmodule, null, b_and_a)
		assert a_and_b.is_subtype(mmodule, null, object_type)
		assert b_and_a.is_subtype(mmodule, null, object_type)

		# Are supertypes of D
		assert d_type.is_subtype(mmodule, null, a_and_b)
		assert d_type.is_subtype(mmodule, null, b_and_a)
	end
end

class TestMIntersectionType
	super TestSuite

	private var mmodule: MModule = create_dummy_mmodule

	fun test_intersection_c_name do
		var a_type = new MTypeStub
		a_type.c_name = "module_foo__A"
		var b_type = new MTypeStub
		b_type.c_name = "module_foo__B"
		var a_and_b = new MIntersectionType.with_operands(
			mmodule, a_type, b_type
		)
		assert a_and_b.c_name == "and2__module_foo__A__module_foo__B"
	end

	fun test_intersection_c_name_notnull do
		var object_type = new MTypeStub
		object_type.c_name = "module_foo__Object"
		object_type.is_object = true
		var foo_type = new MTypeStub
		foo_type.c_name = "module_foo__MyClass__FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, foo_type
		)
		assert not_null_foo.full_name == "not_null__module_foo__MyClass__FOO"
	end

	fun test_intersection_full_name do
		var a_type = new MTypeStub
		a_type.full_name = "module_foo::A"
		var b_type = new MTypeStub
		b_type.full_name = "module_foo::B"
		var a_and_b = new MIntersectionType.with_operands(
			mmodule, a_type, b_type
		)
		assert a_and_b.full_name == "(module_foo::A and module_foo::B)"
	end

	fun test_intersection_full_name_notnull do
		var object_type = new MTypeStub
		object_type.full_name = "module_foo::Object"
		object_type.is_object = true
		var foo_type = new MTypeStub
		foo_type.full_name = "module_foo::MyClass::FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, foo_type
		)
		assert not_null_foo.full_name == "not null module_foo::MyClass::FOO"
	end

	fun test_intersection_to_s do
		var a_type = new MTypeStub
		a_type.to_s = "A"
		var b_type = new MTypeStub
		b_type.to_s = "B"
		var a_and_b = new MIntersectionType.with_operands(
			mmodule, a_type, b_type
		)
		assert a_and_b.to_s == "(A and B)"
	end

	fun test_intersection_to_s_notnull do
		var object_type = new MTypeStub
		object_type.to_s = "Object"
		object_type.is_object = true
		var foo_type = new MTypeStub
		foo_type.to_s = "FOO"
		var not_null_foo = new MIntersectionType.with_operands(
			mmodule, object_type, foo_type
		)
		assert not_null_foo.to_s == "not null FOO"
	end
end

private fun create_dummy_mmodule: MModule do
	return new MModule(
		new Model, null, "module_dummy", new Location(null, 1, 1, 1, 1)
	)
end

private class MTypeStub
	super MType

	redef var c_name is noinit
	redef var depth is noinit
	redef var full_name is noinit
	redef var is_object = false is writable
	redef var is_ok is noinit
	redef var length is noinit
	redef var need_anchor is noinit
	redef var to_s is noinit
end
