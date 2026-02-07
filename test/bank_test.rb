require 'test_helper'

class BankTest < Minitest::Test
  def setup
    super
    @bank = ZenginLite.bank('0001')
    skip "Bank 0001 not found" unless @bank
  end
  
  def test_has_attributes
    refute_nil @bank.code
    refute_nil @bank.name
  end
  
  def test_branch_lookup
    branch = @bank.branch('001')
    assert_instance_of ZenginLite::Branch, branch if branch
  end
  
  def test_branches_list
    branches = @bank.branches(limit: 10)
    assert_kind_of Array, branches
    branches.each do |branch|
      assert_instance_of ZenginLite::Branch, branch
      assert_equal @bank.code, branch.bank_code
    end
  end
  
  def test_to_h
    hash = @bank.to_h
    assert_kind_of Hash, hash
    assert_equal @bank.code, hash[:code]
    assert_equal @bank.name, hash[:name]
  end
  
  def test_inspect
    inspect_str = @bank.inspect
    assert_includes inspect_str, @bank.code
    assert_includes inspect_str, 'ZenginLite::Bank'
  end
end