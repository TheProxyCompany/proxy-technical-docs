# Quickstart: Pydantic to Guaranteed JSON

This guide demonstrates how to use the Proxy Structuring Engine (PSE) with a Hugging Face `transformers` model (using PyTorch) to generate JSON output guaranteed to match a Pydantic schema.

```python
import torch
from transformers import AutoTokenizer, LlamaForCausalLM
from pydantic import BaseModel

# Assuming PSE is installed:
from pse import StructuringEngine
from pse.util.torch_mixin import PSETorchMixin # Optional: Mixin for easy HF integration

# 1. Define your desired output structure using Pydantic
class UserProfile(BaseModel):
    user_id: int
    username: str
    is_active: bool
    roles: list[str]

# 2. (Optional) Apply the PSE mixin to your Hugging Face model class
#    This simplifies integration by adding the `engine` attribute and overriding `generate`.
class PSE_Llama(PSETorchMixin, LlamaForCausalLM):
    pass

# 3. Load your model and tokenizer
#    Replace with your desired model path.
model_path = "meta-llama/Llama-3.2-1B-Instruct"
tokenizer = AutoTokenizer.from_pretrained(model_path)

# Use the mixed-in class or your base model class
model = PSE_Llama.from_pretrained(
    model_path,
    torch_dtype=torch.bfloat16, # Use appropriate dtype for your model/hardware
    device_map="auto"           # Load model efficiently across devices
)

# Ensure padding token is set for generation (important!)
if tokenizer.pad_token is None:
    tokenizer.pad_token = tokenizer.eos_token
# Ensure the model config also reflects the pad token id
if model.config.pad_token_id is None:
     model.config.pad_token_id = tokenizer.pad_token_id

# 4. Create the StructuringEngine instance.
#    If using the mixin, it's automatically attached as `model.engine`.
#    If not using the mixin, instantiate it separately:
#    engine = StructuringEngine(tokenizer)
model.engine = StructuringEngine(tokenizer) # Assumes mixin usage for simplicity

# 5. Configure the engine with your Pydantic model.
#    PSE compiles this into an efficient HSM representation.
model.engine.configure(UserProfile)

# 6. Create your prompt, instructing the LLM to generate the desired structure.
prompt = f"Generate a user profile for user ID 999, username 'tester', active status true, roles ['qa', 'dev']. Output ONLY the JSON object."
messages = [{"role": "user", "content": prompt}]
input_ids = tokenizer.apply_chat_template(
    messages,
    return_tensors="pt",
    add_generation_prompt=True # Crucial for instruction-following models
).to(model.device)

# 7. Generate using the engine's processor and sampler.
#    If using the mixin, `model.generate` is already overridden.
#    If not using the mixin, pass the engine hooks manually:
#    output_ids = model.generate(
#        input_ids,
#        max_new_tokens=150,
#        do_sample=True, # Or False for greedy decoding
#        logits_processor=[engine.process_logits],
#        sampler=engine.sample
#    )
output_ids = model.generate(
    input_ids,
    max_new_tokens=150,
    do_sample=True # Example: using sampling
    # No need to pass hooks explicitly if using the mixin
)

# 8. Decode and parse the guaranteed structured output
#    Extract only the newly generated tokens, excluding the prompt.
output_text = tokenizer.decode(output_ids[0][input_ids.shape[-1]:], skip_special_tokens=True)
print("Raw Output (Guided by PSE):\n", output_text)

# PSE guarantees this output can be parsed directly into your Pydantic model
# Use the engine instance (model.engine if using mixin, or your separate instance)
structured_output: UserProfile = model.engine.get_structured_output(UserProfile)

# Verify the output
if structured_output:
    print("\nParsed Pydantic Object:\n", structured_output)
    # Example Parsed Output:
    # UserProfile(user_id=999, username='tester', is_active=True, roles=['qa', 'dev'])
else:
    print("\nFailed to generate structured output.")

```

This example shows the basic workflow: Define -> Configure -> Generate -> Parse. PSE ensures the `structured_output` reliably conforms to the `UserProfile` Pydantic model.