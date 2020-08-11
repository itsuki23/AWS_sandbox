ActiveRecord::Base.transaction do
    Article.delete_all
    5.times do |index|
        Article.create!(
            title: "title_#{index}",
            body: "body_#{index}"
        )
    end
end



