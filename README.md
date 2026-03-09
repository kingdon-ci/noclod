# noclod (Claude Code Evaluation)

## Important Notice

This project is for **evaluation purposes only**. We are assessing the Claude Code interface as a potential tool for use with your authorized Bedrock API endpoint. This evaluation is part of our ongoing research into code assistance tools and does not constitute acceptance of any commercial terms or create any obligations on behalf of anyone.

**Key Points:**
- This is a non-production, research-oriented evaluation.
- No proprietary information should be used with this tool during evaluation.
- We are not accepting any commercial license terms by conducting this evaluation.
- Official use would require proper procurement, legal review, and authorization.

## Background

You have been provided access to an OpenAI/AWS Bedrock endpoint for code assistance. While continue.dev is the officially sanctioned interface, we are exploring Claude Code as a potentially more effective way to interact with this endpoint.

## Lore

The name **noclod** is a testament to human (and AI) error. During initial testing of the Claude Android app's voice transcription, the phrase "no Claude" was vocalized and subsequently transcribed as "noclod." 

We decided to embrace this "clod-like" interpretation. In this context, **noclod** serves as a reminder that we strive to be smarter than a lump of dirt, even when our tools occasionally suggest otherwise. It's a project dedicated to testing if Claude Code can live up to its name—or if it's just another clod in the field.

## Evaluation Goals

1. Assess the usability and effectiveness of the Claude Code interface.
2. Compare functionality with the continue.dev interface.
3. Identify potential benefits and drawbacks for official use cases.
4. Gather data to support a potential request for official support and proper licensing.

## Setup for Evaluation

#### Clone the proxy repository

```
git clone https://github.com/1rgs/claude-code-proxy.git
cp claude-code-proxy.env claude-code-proxy/.env
cd claude-code-proxy
```

#### Run the proxy server (ensure you have uv installed)

```
uv run uvicorn server:app --host 127.0.0.1 --port 8082 --reload
```

Note there are several competing claude code proxy implementations, yours may
have different startup instructions.

#### In a new terminal, set up the environment

```
source vars
```

#### Run Claude Code (for evaluation purposes only)

```
claude
```

#### When prompted, use the command:

```
# > Tell me about the scripts in this directory.
```

## Important Considerations

- We are using the provided "bedrock-code-api" endpoint for this evaluation.
- Usage is strictly limited to non-sensitive, non-proprietary code and information.
- This evaluation does not imply acceptance of Anthropic's PBC license terms.
- Any potential official use would require proper procurement processes and legal review.

## Next Steps

1. Document findings from this evaluation.
2. Prepare a report comparing Claude Code to continue.dev for our use case.
3. If benefits are identified, contact the Code Assistants Pilot team to:
   - Request consideration of Claude Code as an officially supported interface
   - Inquire about proper licensing and procurement options for official use

## Disclaimer

This evaluation is conducted as part of our research into potential tools for code assistance. It does not create any obligations on behalf of anyone or imply acceptance of any commercial terms. Official use of any commercial software requires proper authorization, procurement, and legal review.
