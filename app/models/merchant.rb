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
end
