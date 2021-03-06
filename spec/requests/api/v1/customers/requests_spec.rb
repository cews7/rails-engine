require 'rails_helper'

describe "Customers", type: :request do
  it 'returns all customers' do
    create_list(:customer, 3)

    get '/api/v1/customers'

    customers = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customers.count).to eq 3
    expect(customers.first[:first_name]).to be_a String
    expect(customers.first[:last_name]).to be_a String
  end

  it 'returns a single customer' do
    create(:customer, first_name: "Peacock")
    create(:customer, first_name: "Jonas")

    get "/api/v1/customers/#{Customer.last.id}"

    customer = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customer[:first_name]).to eq("Jonas")
    expect(customer[:first_name]).to be_a String
    expect(customer[:last_name]).to be_a String
  end

  it 'finds a single customer by first_name' do
    create(:customer, first_name: "Peacock")
    create(:customer, first_name: "Jonas")

    get "/api/v1/customers/find?first_name=#{Customer.last.first_name}"

    customer = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customer[:first_name]).to be_a String
    expect(customer[:first_name]).to eq("Jonas")
    expect(customer[:last_name]).to be_a String
  end

  it 'cant find a single customer by first_name not in invoice' do
    create(:customer, first_name: "Peacock")
    create(:customer, first_name: "Jonas")

    get "/api/v1/customers/find?first_name=jhgsfdlkuhgilsuhdfgkjhsfdguh"
    customer = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customer).to eq(nil)
    expect(response.body).to eq("null")
  end

  it 'finds a single customer by last_name' do
    create_list(:customer, 2)

    get "/api/v1/customers/find?last_name=#{Customer.last.last_name}"

    customer = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customer[:first_name]).to be_a String
    expect(customer[:last_name]).to be_a String
  end

  it 'finds all customers by first_name' do
    create(:customer, first_name: "Peacock")
    create(:customer, first_name: "Peacock")
    create(:customer, first_name: "Jonas")

    get "/api/v1/customers/find_all?first_name=#{Customer.last.first_name}"

    customers = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customers.count).to eq 1
    expect(customers.first[:first_name]).to eq(customers.last[:first_name])
    expect(customers.last[:last_name]).to be_a String
  end

  it 'finds all customers by last_name' do
    create(:customer, last_name: "Peacock")
    create(:customer, last_name: "Peacock")
    create(:customer, last_name: "Jonas")

    get "/api/v1/customers/find_all?last_name=#{Customer.first.last_name}"

    customers = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customers.count).to eq 2
    expect(customers.first[:last_name]).to eq(customers.last[:last_name])
    expect(customers.last[:last_name]).to be_a String
  end

  it 'cant find all customers by last_name not in database' do
    create(:customer, last_name: "Peacock")
    create(:customer, last_name: "Peacock")
    create(:customer, last_name: "Jonas")

    get "/api/v1/customers/find_all?last_name=McLovin"

    customers = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customers).to eq([])
    expect(response.body).to eq("[]")
  end

  it 'finds a random customer' do
    create_list(:customer, 2)

    get "/api/v1/customers/random"

    customer = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_success
    expect(customer[:first_name]).to be_a String
    expect(customer[:last_name]).to be_a String
  end

  it 'returns customer -- updated_at lookup' do
    db_customer = create(:customer)

    get "/api/v1/customers/find?updated_at=#{db_customer.updated_at}"

    expect(response).to be_success

    customer_attrs = JSON.parse(response.body, symbolize_names: true)

    expect(customer_attrs.count).to eq 3
    expect(customer_attrs).to have_key(:first_name)
    expect(customer_attrs).to have_key(:last_name)
  end

  it 'returns customer -- created_at lookup' do
    db_customer = create(:customer)

    get "/api/v1/customers/find?created_at=#{db_customer.created_at}"

    expect(response).to be_success

    customer_attrs = JSON.parse(response.body, symbolize_names: true)

    expect(customer_attrs.count).to eq 3
    expect(customer_attrs).to have_key(:first_name)
    expect(customer_attrs).to have_key(:last_name)
  end
end
