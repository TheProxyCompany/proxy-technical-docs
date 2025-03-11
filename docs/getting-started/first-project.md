# Your First PSE Project

This guide walks you through building a complete project with the Proxy Structuring Engine (PSE). We'll create a practical application that demonstrates PSE's capabilities in a real-world scenario: a customer support assistant that can extract structured information from customer inquiries and generate appropriate responses.

## Project Overview

Our customer support assistant will:

1. Extract structured data from customer inquiries
2. Classify the type of support request
3. Generate structured responses with formatting guidance
4. Include relevant action items for the customer or support team

This project demonstrates several key PSE capabilities:
- Data extraction from unstructured text
- Natural language generation with structural constraints
- Composite engine usage for thinking/explanation
- Multi-step processing pipeline

## Step 1: Setup Environment

First, let's set up our project environment:

```bash
# Create a project directory
mkdir customer-support-assistant
cd customer-support-assistant

# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install required packages
pip install pse torch transformers
```

## Step 2: Define Project Structure

Create the following files in your project directory:

```
customer-support-assistant/
├── schemas/
│   ├── inquiry_schema.py
│   ├── classification_schema.py
│   └── response_schema.py
├── models.py
├── assistant.py
└── demo.py
```

## Step 3: Define JSON Schemas

Let's define the schemas for our application:

### schemas/inquiry_schema.py

```python
"""Schema for extracting information from customer inquiries."""

INQUIRY_SCHEMA = {
    "type": "object",
    "properties": {
        "customer": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "email": {"type": "string"},
                "account_id": {"type": "string"}
            },
            "required": ["name"]
        },
        "product": {
            "type": "object",
            "properties": {
                "name": {"type": "string"},
                "version": {"type": "string"},
                "purchase_date": {"type": "string"}
            },
            "required": ["name"]
        },
        "issue": {
            "type": "object",
            "properties": {
                "description": {"type": "string"},
                "first_occurred": {"type": "string"},
                "frequency": {"type": "string", "enum": ["once", "occasionally", "frequently", "constantly"]}
            },
            "required": ["description"]
        },
        "attempted_solutions": {
            "type": "array",
            "items": {"type": "string"}
        }
    },
    "required": ["customer", "issue"]
}
```

### schemas/classification_schema.py

```python
"""Schema for classifying customer inquiries."""

CLASSIFICATION_SCHEMA = {
    "type": "object",
    "properties": {
        "category": {
            "type": "string", 
            "enum": ["technical", "billing", "account", "product", "other"]
        },
        "priority": {
            "type": "string",
            "enum": ["low", "medium", "high", "critical"]
        },
        "requires_specialist": {"type": "boolean"},
        "estimated_resolution_time": {
            "type": "string",
            "enum": ["immediate", "within 24 hours", "1-3 days", "over 3 days"]
        }
    },
    "required": ["category", "priority"]
}
```

### schemas/response_schema.py

```python
"""Schema for structured support responses."""

RESPONSE_SCHEMA = {
    "type": "object",
    "properties": {
        "greeting": {"type": "string"},
        "understanding": {"type": "string"},
        "solution": {
            "type": "object",
            "properties": {
                "explanation": {"type": "string"},
                "steps": {
                    "type": "array",
                    "items": {"type": "string"}
                }
            },
            "required": ["explanation", "steps"]
        },
        "action_items": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "for": {"type": "string", "enum": ["customer", "support_team", "specialist"]},
                    "action": {"type": "string"},
                    "deadline": {"type": "string"}
                },
                "required": ["for", "action"]
            }
        },
        "closing": {"type": "string"}
    },
    "required": ["greeting", "understanding", "solution", "closing"]
}
```

## Step 4: Create Model Loading Module

### models.py

```python
"""Model loading utilities for the customer support assistant."""

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

def load_model(model_name="meta-llama/Llama-3-8b-instruct", device="auto"):
    """
    Load a language model and tokenizer.
    
    Args:
        model_name: The name of the model to load
        device: Device to load the model on ('cpu', 'cuda', 'auto')
        
    Returns:
        tuple: (model, tokenizer)
    """
    # Determine device
    if device == "auto":
        device = "cuda" if torch.cuda.is_available() else "cpu"
    
    print(f"Loading model {model_name} on {device}...")
    
    # Load tokenizer
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    
    # Load model
    model = AutoModelForCausalLM.from_pretrained(
        model_name,
        torch_dtype=torch.float16 if device == "cuda" else torch.float32,
        device_map=device
    )
    
    return model, tokenizer
```

## Step 5: Implement the Assistant

### assistant.py

```python
"""Customer support assistant using PSE."""

from pse import StructuringEngine, NaturalLanguageEngine
from pse.util.torch_mixin import TorchStructuringEngine

from schemas.inquiry_schema import INQUIRY_SCHEMA
from schemas.classification_schema import CLASSIFICATION_SCHEMA
from schemas.response_schema import RESPONSE_SCHEMA

class CustomerSupportAssistant:
    """Assistant for handling customer support inquiries using PSE."""
    
    def __init__(self, model, tokenizer):
        """
        Initialize the assistant with a model and tokenizer.
        
        Args:
            model: Language model
            tokenizer: Tokenizer for the model
        """
        self.model = model
        self.tokenizer = tokenizer
        
        # Create structuring engines
        self.inquiry_engine = TorchStructuringEngine.from_json_schema(INQUIRY_SCHEMA)
        self.classification_engine = TorchStructuringEngine.from_json_schema(CLASSIFICATION_SCHEMA)
        
        # Create a composite engine for responses with thinking space
        self.response_engine = TorchStructuringEngine.create_composite_engine(
            {
                "thinking": NaturalLanguageEngine(),
                "output": TorchStructuringEngine.from_json_schema(RESPONSE_SCHEMA)
            },
            delimiter_tokens={
                "thinking_to_output": ["\nStructured Response:\n"]
            }
        )
    
    def extract_inquiry_data(self, customer_message):
        """
        Extract structured data from customer inquiry.
        
        Args:
            customer_message: The customer's support request
            
        Returns:
            str: JSON representation of extracted information
        """
        prompt = f"Extract structured information from this customer support request:\n\n{customer_message}"
        input_ids = self.tokenizer.encode(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.inquiry_engine.generate(
            self.model,
            input_ids,
            max_new_tokens=500,
            temperature=0.2
        )
        
        result = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        return result
    
    def classify_inquiry(self, inquiry_data, customer_message):
        """
        Classify the type and priority of the support request.
        
        Args:
            inquiry_data: Structured inquiry data
            customer_message: Original customer message
            
        Returns:
            str: JSON representation of classification
        """
        prompt = f"""
        Classify this customer support request:
        
        Original request:
        {customer_message}
        
        Extracted data:
        {inquiry_data}
        """
        
        input_ids = self.tokenizer.encode(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.classification_engine.generate(
            self.model,
            input_ids,
            max_new_tokens=200,
            temperature=0.3
        )
        
        result = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        return result
    
    def generate_response(self, inquiry_data, classification, customer_message):
        """
        Generate a structured response to the customer inquiry.
        
        Args:
            inquiry_data: Structured inquiry data
            classification: Inquiry classification
            customer_message: Original customer message
            
        Returns:
            str: Structured response with thinking
        """
        prompt = f"""
        Generate a helpful customer support response:
        
        Original request:
        {customer_message}
        
        Extracted data:
        {inquiry_data}
        
        Classification:
        {classification}
        
        Think through how to best help this customer, and then provide a structured response.
        """
        
        input_ids = self.tokenizer.encode(prompt, return_tensors="pt").to(self.model.device)
        
        outputs = self.response_engine.generate(
            self.model,
            input_ids,
            max_new_tokens=1000,
            temperature=0.7
        )
        
        result = self.tokenizer.decode(outputs[0], skip_special_tokens=True)
        return result
    
    def process_inquiry(self, customer_message):
        """
        Process a customer inquiry from start to finish.
        
        Args:
            customer_message: The customer's support request
            
        Returns:
            dict: The complete process results
        """
        print("1. Extracting structured data from inquiry...")
        inquiry_data = self.extract_inquiry_data(customer_message)
        
        print("2. Classifying inquiry...")
        classification = self.classify_inquiry(inquiry_data, customer_message)
        
        print("3. Generating structured response...")
        response = self.generate_response(inquiry_data, classification, customer_message)
        
        return {
            "inquiry_data": inquiry_data,
            "classification": classification,
            "response": response
        }
```

## Step 6: Create a Demo Application

### demo.py

```python
"""Demo application for customer support assistant."""

import json
import sys
from models import load_model
from assistant import CustomerSupportAssistant

# Sample customer inquiries for testing
SAMPLE_INQUIRIES = [
    """
    Hello, my name is Sarah Johnson and I'm having trouble with my SmartHome Hub (v2.3) that I purchased last month. 
    The device is not connecting to my WiFi network even though all my other devices connect fine. 
    I've already tried resetting the hub, checking my WiFi password, and moving it closer to the router, but nothing works.
    This started happening yesterday and occurs every time I try to set it up. My email is sarah.j@example.com.
    Please help!
    """,
    
    """
    Hi support team, I'm Michael Chen (account #AC-45729). I was charged twice for my premium subscription on March 15th. 
    I only have one active account, so this seems like a billing error. Can you please refund the duplicate charge? 
    This is the first time I've had an issue with billing.
    """
]

def format_json(json_str):
    """Format JSON string for better readability."""
    try:
        parsed = json.loads(json_str)
        return json.dumps(parsed, indent=2)
    except:
        return json_str

def main():
    # Load model and tokenizer
    model, tokenizer = load_model()
    
    # Initialize the assistant
    assistant = CustomerSupportAssistant(model, tokenizer)
    
    # Choose sample inquiry or get user input
    if len(sys.argv) > 1 and sys.argv[1] == "--interactive":
        print("Enter your customer support inquiry (Ctrl+D or Ctrl+Z to submit):")
        customer_message = sys.stdin.read().strip()
    else:
        print("Using sample inquiry. Run with --interactive for custom input.")
        inquiry_index = 0
        if len(sys.argv) > 1 and sys.argv[1].isdigit():
            inquiry_index = int(sys.argv[1]) % len(SAMPLE_INQUIRIES)
        customer_message = SAMPLE_INQUIRIES[inquiry_index]
        print("\nCustomer Inquiry:")
        print("-" * 80)
        print(customer_message)
        print("-" * 80)
    
    # Process the inquiry
    results = assistant.process_inquiry(customer_message)
    
    # Display results
    print("\n=== EXTRACTED INQUIRY DATA ===")
    print(format_json(results["inquiry_data"]))
    
    print("\n=== INQUIRY CLASSIFICATION ===")
    print(format_json(results["classification"]))
    
    print("\n=== SUPPORT RESPONSE ===")
    print(results["response"])

if __name__ == "__main__":
    main()
```

## Step 7: Run the Demo

Now you can run your customer support assistant:

```bash
# Run with the first sample inquiry
python demo.py

# Run with the second sample inquiry
python demo.py 1

# Run with interactive input
python demo.py --interactive
```

## Example Output

Here's what the output might look like for the first sample inquiry:

```
Loading model meta-llama/Llama-3-8b-instruct on cuda...
1. Extracting structured data from inquiry...
2. Classifying inquiry...
3. Generating structured response...

=== EXTRACTED INQUIRY DATA ===
{
  "customer": {
    "name": "Sarah Johnson",
    "email": "sarah.j@example.com"
  },
  "product": {
    "name": "SmartHome Hub",
    "version": "v2.3",
    "purchase_date": "last month"
  },
  "issue": {
    "description": "Device not connecting to WiFi network",
    "first_occurred": "yesterday",
    "frequency": "constantly"
  },
  "attempted_solutions": [
    "resetting the hub",
    "checking WiFi password",
    "moving it closer to the router"
  ]
}

=== INQUIRY CLASSIFICATION ===
{
  "category": "technical",
  "priority": "medium",
  "requires_specialist": false,
  "estimated_resolution_time": "within 24 hours"
}

=== SUPPORT RESPONSE ===
I need to craft a helpful response for Sarah who is having WiFi connectivity issues with her recently purchased SmartHome Hub. She's already tried the basic troubleshooting steps like resetting the hub, checking her password, and adjusting the location. This is clearly a technical issue that needs a systematic approach to resolve.

I'll start with a friendly greeting that acknowledges her by name, express understanding of her frustration, provide clear troubleshooting steps beyond what she's already tried, and give her specific action items. Since the issue seems to be of medium priority and doesn't require a specialist, I can likely help her resolve this directly.

Structured Response:
{
  "greeting": "Hello Sarah,",
  "understanding": "Thank you for reaching out about your SmartHome Hub v2.3 connectivity issues. I understand how frustrating it can be when your smart home devices won't connect to WiFi, especially when all your other devices are working properly.",
  "solution": {
    "explanation": "Based on your description, there appear to be a few additional troubleshooting steps we can try that might resolve this connectivity issue. Since you've already tried the basic steps like resetting the hub and checking your WiFi password, let's move on to some more specific solutions.",
    "steps": [
      "Check your router's settings - Some routers have settings that can interfere with IoT devices. Ensure that your router is not blocking unknown devices and that MAC filtering is disabled.",
      "Update your router's firmware - Outdated router firmware can sometimes cause connectivity issues with newer smart devices.",
      "Try connecting to the 2.4GHz network specifically - Many smart home devices don't support 5GHz networks, so make sure your hub is connecting to the 2.4GHz band.",
      "Perform a factory reset on the hub - Press and hold the reset button for 10 seconds until the LED indicator flashes rapidly, then release.",
      "Try setting up the hub using a mobile hotspot - This can help determine if the issue is specific to your home network."
    ]
  },
  "action_items": [
    {
      "for": "customer",
      "action": "Try the advanced troubleshooting steps listed above, starting with connecting to the 2.4GHz network specifically.",
      "deadline": "At your earliest convenience"
    },
    {
      "for": "customer",
      "action": "If none of these solutions work, please reply to this email with the results of your attempts and any error messages displayed on the app during setup.",
      "deadline": "Within 48 hours"
    },
    {
      "for": "support_team",
      "action": "Check for any recent firmware updates for the SmartHome Hub v2.3 that address WiFi connectivity issues.",
      "deadline": "Before follow-up"
    }
  ],
  "closing": "If you continue to experience issues after trying these steps, please don't hesitate to reach back out. We're committed to helping you get your SmartHome Hub up and running smoothly.\n\nBest regards,\nThe Support Team"
}
```

## Next Steps

You've successfully built a customer support assistant using PSE! This project demonstrates several key capabilities:

1. **Extraction**: Converting unstructured customer inquiries to structured data
2. **Classification**: Categorizing and prioritizing support requests
3. **Composite Engines**: Using thinking space with structured output
4. **Multi-step Processing**: Building a complete pipeline from inquiry to response

To extend this project, you could:

- Add a database to store customer interactions
- Implement a feedback mechanism to improve responses
- Create a web interface for the assistant
- Integrate with a ticketing system for escalations
- Add support for multiple languages

For more advanced PSE features, explore:

- [JSON Schema Integration](../guides/json-schema.md) for more complex schemas
- [Token Healing](../core-concepts/token-healing.md) for better error recovery
- [Framework Adapters](../api/framework-adapters.md) for different ML frameworks
- [Structuring Engine API](../api/structuring-engine.md) for detailed configuration options