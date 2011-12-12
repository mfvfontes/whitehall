require 'test_helper'

class NewsArticlesControllerTest < ActionController::TestCase
  should_render_a_list_of :news_articles

  test "shows published news article" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    assert_response :success
  end

  test "renders the news article body using govspeak" do
    news_article = create(:published_news_article, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: news_article.document_identity

    assert_select ".body", text: "body-in-html"
  end

  test "renders the news article notes to editors using govspeak" do
    news_article = create(:published_news_article, notes_to_editors: "notes-to-editors-in-govspeak")
    Govspeak::Document.stubs(:to_html).returns("\n")
    Govspeak::Document.stubs(:to_html).with("notes-to-editors-in-govspeak").returns("notes-to-editors-in-html")

    get :show, id: news_article.document_identity

    assert_select "#{notes_to_editors_selector}", text: /notes-to-editors-in-html/
  end

  test "excludes the notes to editors section if they're empty" do
    news_article = create(:published_news_article, notes_to_editors: "")
    get :show, id: news_article.document_identity
    refute_select "#{notes_to_editors_selector}"
  end

  test "shows when news article was last updated" do
    news_article = create(:published_news_article, published_at: 10.days.ago)

    get :show, id: news_article.document_identity

    assert_select ".document_view .metadata" do
      assert_select ".published_at", text: "10 days ago"
    end
  end

  test 'show displays related published policies' do
    published_policy = create(:published_policy)
    news_article = create(:published_news_article, related_documents: [published_policy])
    get :show, id: news_article.document_identity
    assert_select_object published_policy
  end

  test 'show doesn\'t display related unpublished policies' do
    draft_policy = create(:draft_policy)
    news_article = create(:published_news_article, related_documents: [draft_policy])
    get :show, id: news_article.document_identity
    refute_select_object draft_policy
  end

  test 'show infers policy areas from published policies' do
    policy_area = create(:policy_area)
    published_policy = create(:published_policy, policy_areas: [policy_area])
    news_article = create(:published_news_article, related_documents: [published_policy])
    get :show, id: news_article.document_identity
    assert_select_object policy_area
  end

  test "should not display policies unless they are related to the news article" do
    unrelated_policy = create(:published_policy)
    news_article = create(:published_news_article, related_documents: [])
    get :show, id: news_article.document_identity
    refute_select_object unrelated_policy
  end

  test "should not display an empty list of related policies" do
    news_article = create(:published_news_article)
    get :show, id: news_article.document_identity
    refute_select "#related-policies"
  end

  test "should display countries to which this news article relates" do
    first_country = create(:country)
    second_country = create(:country)
    news_article = create(:published_news_article, countries: [first_country, second_country])

    get :show, id: news_article.document_identity

    assert_select "#countries" do
      assert_select_object(first_country)
      assert_select_object(second_country)
    end
  end

  test "should not display an empty list of countries" do
    news_article = create(:published_news_article, countries: [])

    get :show, id: news_article.document_identity

    refute_select "#countries"
  end
end