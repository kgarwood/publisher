require 'test_helper'

class TransactionPresenterTest < ActiveSupport::TestCase
  include GovukContentSchemaTestHelpers::TestUnit

  def subject
    Formats::TransactionPresenter.new(edition)
  end

  def edition
    @_edition ||= FactoryGirl.create(:transaction_edition, panopticon_id: artefact.id)
  end

  def artefact
    @_artefact ||= FactoryGirl.create(:artefact, kind: "transaction")
  end

  def result
    subject.render_for_publishing_api
  end

  should "be valid against schema" do
    assert_valid_against_schema(result, 'transaction')
  end

  should "[:schema_name]" do
    assert_equal 'transaction', result[:schema_name]
  end

  context "[:details]" do
    should "[:introductory_paragraph]" do
      edition.update_attribute(:introduction, 'foo')
      expected = [
        {
          content_type: 'text/govspeak',
          content: 'foo'
        }
      ]
      assert_equal expected, result[:details][:introductory_paragraph]
    end

    should "[:more_information]" do
      edition.update_attribute(:more_information, 'foo')
      expected = [
        {
          content_type: 'text/govspeak',
          content: 'foo'
        }
      ]
      assert_equal expected, result[:details][:more_information]
    end

    should "[:other_ways_to_apply]" do
      edition.update_attribute(:alternate_methods, 'foo')
      expected = [
        {
          content_type: 'text/govspeak',
          content: 'foo'
        }
      ]
      assert_equal expected, result[:details][:other_ways_to_apply]
    end

    should "[:what_you_need_to_know]" do
      edition.update_attribute(:need_to_know, 'foo')
      expected = [
        {
          content_type: 'text/govspeak',
          content: 'foo'
        }
      ]
      assert_equal expected, result[:details][:what_you_need_to_know]
    end

    should "[:external_related_links]" do
      link = { 'url' => 'www.foo.com', 'title' => 'foo' }
      artefact.update_attribute(:external_links, [link])
      expected = [
        {
          url: link['url'],
          title: link['title']
        }
      ]

      assert_equal expected, result[:details][:external_related_links]
    end

    should "[:will_continue_on]" do
      edition.update_attribute(:will_continue_on, "foo")
      assert_equal "foo", result[:details][:will_continue_on]
    end

    should "[:transaction_start_link]" do
      edition.update_attribute(:link, "foo")
      assert_equal "foo", result[:details][:transaction_start_link]
    end

    should "[:department_analytics_profile]" do
      edition.update_attribute(:department_analytics_profile, 'UA-000000-2')
      assert_equal 'UA-000000-2', result[:details][:department_analytics_profile]
    end
  end

  should "[:routes]" do
    edition.update_attribute(:slug, 'foo')
    expected = [
      { path: '/foo', type: 'exact' },
      { path: '/foo.json', type: 'exact' }
    ]
    assert_equal expected, result[:routes]
  end
end
