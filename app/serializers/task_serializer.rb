class TaskSerializer < ActiveModel::Serializer
  attributes :id, :products, :total

  def products
    object.task_items.group_by(&:product_id).map do |_key, value|
      product = value.uniq(&:product_id)[0].product
      { amount: value.size, name: product.name, total: (value.size * product.price) }
    end
  end

  def total
    object.task_items.joins(:product).sum("products.price")
  end
end
