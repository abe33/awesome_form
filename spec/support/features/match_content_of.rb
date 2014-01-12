class RSpec::Core::ExampleGroup
  def match_content_of(page, match)

    AwesomeForm::DOM::DomExpression.new(match, self).match(page)
  end
end
