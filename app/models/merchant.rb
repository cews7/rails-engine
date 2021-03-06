class Merchant < ApplicationRecord
  validates :name, presence: true
  has_many :items
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :customers, through: :invoices
  has_many :transactions, through: :invoices

  def favorite_customer
    customers.joins(:transactions)
    .merge(Transaction.successful)
    .group(:id).order('count(transactions) DESC').first
  end

  def self.most_items(quantity)
    joins(invoices: [:invoice_items, :transactions])
    .merge(Transaction.successful)
    .group('merchants.id')
    .order('sum(invoice_items.quantity) desc')
    .limit(quantity)
  end

  def self.revenue(date = nil, id)
    return revenue_by_date(date, id) if date
    joins(invoices: [:invoice_items, :transactions])
    .merge(Transaction.successful)
    .where(invoices: {merchant_id: id})
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def self.revenue_by_date(date, id)
    joins(invoices: [:invoice_items, :transactions])
    .merge(Transaction.successful)
    .where(invoices: {created_at: date})
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def self.most_revenue(number_of_returns)
    joins(invoices: [:transactions, :invoice_items])
    .merge(Transaction.successful)
    .group(:id).order("sum(quantity * unit_price) DESC")
    .limit(number_of_returns)
  end

  def self.all_merchant_revenue(date)
    joins(invoices: [:invoice_items, :transactions])
    .merge(Transaction.successful)
    .where(invoices: {created_at: date})
    .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def customers_with_pending_invoices
    Customer.find_by_sql("select customers.* from customers
      join invoices
      on customers.id = invoices.customer_id
      where invoices.id in (
        select invoices.id
        from invoices
        join transactions
        on invoices.id = transactions.invoice_id
        where transactions.result = 'failed'
        and invoices.merchant_id = #{self.id}
        except
        select invoices.id
        from invoices
        join transactions
        on invoices.id = transactions.invoice_id
        where transactions.result = 'success'
        and invoices.merchant_id = #{self.id}
      )
      and invoices.merchant_id = #{self.id};")
  end
end
