{
  title: 'Stripe',

  connection: {

    fields: [
      {
        name: "token",
        control_type: "string",
        label: "Bearer token",
        optional: false,
        hint: "API Key available in 'Stripe Dashboard' page"
      }
    ],

    authorization: {
      type: 'custom_auth',

      apply: lambda do |connection|
        headers("Authorization": "Bearer #{connection["token"]}")
		
      end
    },

    base_uri: lambda do |connection|
      "https://api.stripe.com"
	  
    end
  },

    test: lambda do |_connection|
    get("v1/charges")
	
  end,

 object_definitions: {
    #  Object definitions can be referenced by any input or output fields in actions/triggers.
    #  Use it to keep your code DRY. Possible arguments - connection, config_fields
    #  See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/object_definitions.html
    customer: {
      fields: lambda do |_connection, _config_fields|
        [
          { name: "id" }
        ]
		
      end
    },
   product: {
      fields: lambda do |_connection, _config_fields|
        
          { name: "name" }
        
      end
    },

    get_event: {
      fields: lambda do
        
          { name: "id" }
        
      end
    },
   post_event: {
      fields: lambda do
        
          { name: "name" }
        
      end
    },

    get_event_types: {
      fields: lambda do
        
        { name: "id" }
        
      end
    },
   post_event_types: {
      fields: lambda do
        
        { name: "name" }
        
      end
    }
  },

actions: {
     get_customer_new: {
       title: "Get a Customer",

      subtitle: "Retrieves details of an customer in Stripe",
       input_fields: lambda do |object_definitions|
        [
          {
            name: "id",
            label: "Customer ID",
            hint: "The ID of the specific account that you wish to retrieve."
          }
        ]
		
      end,
       execute: lambda do |connection, input|
         get("https://api.stripe.com/v1/customers/#{input['id']}")
		 
       end,
       output_fields: lambda do |object_definitions|
         [
          {
            name: 'id',
          },
          {
            name: 'email'
          },          
          {
            name: 'name'
          },
          {
            name: 'object'
          },
          {
            name: 'description'
          },
          {
            name: 'created'
          },
          {
            name: 'discount'
          }
        ]
		
      end
     },
    
    create_product: {
      title: 'Create Product',

      subtitle: "Create an Product in Srtipe",

      description: lambda do |input|
        "Create <span class='provider'>product</span> in <span class='provider'>Stripe</span>"
		
      end,

      help: "Create a new product in Stripe",

      input_fields: lambda do |object_definitions|
        [
        {
            name: "product_name",
            label: "Product Name",
            hint: "Creates a new product object.",
            optional: false
          }
        ]
		
      end,

      execute: lambda do |connection, input|
       puts post("https://api.stripe.com/v1/products/#{input['product_name']}").
          request_body(
            puts input.reject { |k,v| k == 'product_name' }
          ).
          puts request_format_www_form_urlencoded
        
         end,
        
#               execute: lambda do |connection, input|
#         post("https://forms.hubspot.com/uploads/form/v2/#{input['portal_id']}/#{input['form_guid']}").
#           request_body(
#             input.reject { |k,v| k == 'portal_id' || k == 'form_guid' }
#           ).
#           request_format_www_form_urlencoded
        
     

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'id',
          },          
          {
            name: 'name'
          },
          {
            name: 'description'
          },
        ]
		
      end,

      sample_output: lambda do |connection, input|
        {
  "id": "prod_JUEBaqh3VHA6F8",
  "object": "product",
  "active": true,
  "created": 1621055265,
  "description": "Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.",
  "images": [
    "http://localhost:3000/images/cookie-tin.jpg"
  ],
  "livemode": false,
  "metadata": {},
  "name": "Gold Special",
  "package_dimensions": null,
  "shippable": null,
  "statement_descriptor": null,
  "unit_label": null,
  "updated": 1621055265,
  "url": null
}

      end
    }
  },

triggers: {
    get_customer: {
      title: 'Get a Customer',

      subtitle: "Triggers to get a customer from Stripe",

      description: lambda do |input|
        "Get <span class='provider'>customer</span> in <span class='provider'>Stripe</span>"
		
      end,

      help: "Retrieves the details of an existing customer.",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'Event name',
            label: 'Event name',
            type: 'string',
            optional: true,
          },{
            name: 'URL',
            label: 'URL',
            type: 'string',
            optional: false,
          },
          {
            name: 'Response content type',
            label: 'Response content type',
            type: 'string',
            optional: true,
          },
          {
            name: 'Response body example',
            label: 'Response body example',
            type: 'string',
            optional: true,
          }, 
          {
            name: 'Array Path',
            label: 'Array Path',
            type: 'object',
            properties: [],
            optional: true,
          }
        ]
		
      end,

      poll: lambda do |connection, input, closure|

        closure = {} unless closure.present?

        page_size = 10

        created = (closure['created'] || input['created'] || Time.now ).to_time.utc.iso8601

        customer = get("https://api.stripe.com/v1/customers?starting_after")

        closure['created'] = customer.blank?

        {
          events: customer,
          next_poll: closure,
          can_poll_more: customer.length >= page_size
        }
		
      end,

      dedup: lambda do |record|
        "#{record['id']}@#{record['created']}"
		
      end,

      output_fields: lambda do |object_definitions|
        [
          {
            name: 'id',
          },
          {
            name: 'email'
          },          
          {
            name: 'name'
          },
          {
            name: 'object'
          },
          {
            name: 'description'
          },
          {
            name: 'created'
          },
          {
            name: 'discount'
          }
        ]
		
      end,

      sample_output: lambda do |connection, input|
        {
    
    "object": "list",
    "data": [
        {
            "id": "cus_JULsbt8orNIsiX",
            "object": "customer",
            "address": null,
            "balance": 0,
            "created": 1621083902,
            "currency": null,
            "default_source": null,
            "delinquent": false,
            "description": null,
            "discount": null,
            "email": "pawarabhishek512@gmail.com",
            "invoice_prefix": "E9A7F5D3",
            "invoice_settings": {
                "custom_fields": null,
                "default_payment_method": null,
                "footer": null
            },
            "livemode": false,
            "metadata": {},
            "name": "Abhishek Pawar",
            "next_invoice_sequence": 1,
            "phone": null,
            "preferred_locales": [],
            "shipping": null,
            "tax_exempt": "none"
        },
        {
            "id": "cus_JULWcglsBmO37l",
            "object": "customer",
            "address": null,
            "balance": 0,
            "created": 1621082557,
            "currency": null,
            "default_source": null,
            "delinquent": false,
            "description": null,
            "discount": null,
            "email": "TimDoe@gmail.com",
            "invoice_prefix": "A80EC25A",
            "invoice_settings": {
                "custom_fields": null,
                "default_payment_method": null,
                "footer": null
            },
            "livemode": false,
            "metadata": {},
            "name": "Tim Doe",
            "next_invoice_sequence": 1,
            "phone": null,
            "preferred_locales": [],
            "shipping": null,
            "tax_exempt": "none"
        },
        {
            "id": "cus_JULV1aOmNAhLgu",
            "object": "customer",
            "address": null,
            "balance": 0,
            "created": 1621082535,
            "currency": null,
            "default_source": null,
            "delinquent": false,
            "description": null,
            "discount": null,
            "email": "JonathonDoe@gmail.com",
            "invoice_prefix": "DCAB7D8A",
            "invoice_settings": {
                "custom_fields": null,
                "default_payment_method": null,
                "footer": null
            },
            "livemode": false,
            "metadata": {},
            "name": "Jonathon Doe",
            "next_invoice_sequence": 1,
            "phone": null,
            "preferred_locales": [],
            "shipping": null,
            "tax_exempt": "none"
        }
    ],
    "has_more": false,
    "url": "/v1/customers"

}
      end
    },

    create_product: {
      title: 'Create Product',

      subtitle: "Triggers when a product is created in Stripe",

      description: lambda do |input|
        "Create <span class='provider'>product</span> in <span class='provider'>Stripe</span>"
		
      end,

      help: "Creates a new product object.",

      input_fields: lambda do |object_definitions|
        [
          {
            name: 'name',
            label: 'Product Name',
            type: 'string',
            optional: false,
          }
        ]
		
      end,
      
      poll: lambda do |connection, input, closure|
        
        page_size = 10
        
        created = (closure['created'] || input['created'] || Time.now ).to_time.utc.iso8601
        
        response = get("https://api.stripe.com/v1/products")
     
        closure['created'] = response.blank?
        
          {
          events: response,
          next_poll: closure,
          can_poll_more: response.length >= page_size
        }
		
      end,
      
      dedup: lambda do |record|
        "#{record['id']}"
		
        end,

      output_fields: lambda do |object_definitions|
        ["id"]
		
      end,

      sample_output: lambda do |connection, input|
    {
  "id": "prod_JdfDmFvDnVlZsp",
  "object": "product",
  "active": true,
  "created": 1623231563,
  "description": null,
  "images": [],
  "livemode": false,
  "metadata": {},
  "name": "Gold Special",
  "package_dimensions": null,
  "shippable": null,
  "statement_descriptor": null,
  "unit_label": null,
  "updated": 1623231563,
  "url": null
    }
	
      end
    }
},

  pick_lists: {
    # Picklists can be referenced by inputs fields or object_definitions
    # possible arguements - connection
    # see more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/picklists.html
    event_type: lambda do
      [
        # Display name, value
        %W[Event\ Created invitee.created],
        %W[Event\ Canceled invitee.canceled],
        %W[All\ Events all]
      ]
	  
    end

    # folder: lambda do |connection|
    #   get("https://www.wrike.com/api/v3/folders")["data"].
    #     map { |folder| [folder["title"], folder["id"]] }
    # end
  },

  # Reusable methods can be called from object_definitions, picklists or actions
  # See more at https://docs.workato.com/developing-connectors/sdk/sdk-reference/methods.html
  methods: {
  }
}