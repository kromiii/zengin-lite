require 'test_helper'

class BranchTest < Minitest::Test
  def setup
    super
    @branch = ZenginLite.branch(bank_code: '0001', branch_code: '001')
    skip "Branch not found" unless @branch
  end
  
  def test_has_attributes
    refute_nil @branch.code
    refute_nil @branch.bank_code
    refute_nil @branch.name
  end
  
  def test_bank_association
    bank = @branch.bank
    assert_instance_of ZenginLite::Bank, bank
    assert_equal @branch.bank_code, bank.code
  end
  
  def test_to_h
    hash = @branch.to_h
    assert_kind_of Hash, hash
    assert_equal @branch.code, hash[:code]
    assert_equal @branch.name, hash[:name]
  end
  
  def test_inspect
    inspect_str = @branch.inspect
    assert_includes inspect_str, @branch.code
    assert_includes inspect_str, 'ZenginLite::Branch'
  end
end