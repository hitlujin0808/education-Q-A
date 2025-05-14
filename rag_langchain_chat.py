"""
This file demonstrates how to integrate the RAGSystem with LangChain
to achieve multi-turn conversation. It summarizes the user's entire 
conversation history to form a RAG query, retrieves augmented context, 
and includes the entire conversation history for the final answer from the LLM.

Usage:
1. Ensure you have installed langchain, openai, etc.
   pip install langchain openai

2. Set your OpenAI API key as an environment variable:
   export OPENAI_API_KEY="sk-..."

3. Run this file:
   python rag_langchain_chat.py

4. Type in your queries at the prompt to chat over multiple turns.
"""

import os
import sys

from rag_system import RAGSystem
from langchain_openai import ChatOpenAI
from langchain.memory import ConversationBufferMemory

from langchain_core.prompts import (
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate,
    ChatPromptTemplate,
    MessagesPlaceholder
)

from langchain_core.runnables import RunnableSequence

DOMAIN_NAME = "K-12 education"
DEFAULT_DATA_DIR = "edu_docs"
DEFAULT_PERSIST_DIR = "vector_k11"

SUMMARY_PROMPT = """
You are a helpful assistant. Summarize the following entire conversation in one or two sentences, capturing the essential questions or requests:

Conversation History: {conversation_history}

Summary:
"""

CHAT_SYSTEM_PROMPT = f"""
You are a knowledgeable assistant specialised in {DOMAIN_NAME}.
You have additional context from a retrieval system (RAG):

{{rag_context}}

Use this context, plus your general knowledge, to answer the user's latest question.
When a concept is grade-specific (e.g., grade 7 math vs. grade 12 physics), clearly indicate the appropriate grade level.
Provide clear, concise, and age-appropriate explanations. If the information is not found, reply honestly and suggest next steps.
"""

class RAGLangChainChat:
    def __init__(
        self,
        data_dir: str = DEFAULT_DATA_DIR,
        persist_dir: str = DEFAULT_PERSIST_DIR,
        openai_api_key: str | None = None,
        model_name: str = "gpt-4o",
        temperature: float = 0.0
    ):
        self.rag_system = RAGSystem(data_dir=data_dir, persist_dir=persist_dir)

        if openai_api_key:
            os.environ["OPENAI_API_KEY"] = openai_api_key

        self.chat_model = ChatOpenAI(
            model=model_name,
            temperature=temperature
        )

        self.memory = ConversationBufferMemory(return_messages=True)

        summarize_prompt = ChatPromptTemplate.from_messages([
            SystemMessagePromptTemplate.from_template(SUMMARY_PROMPT)
        ])
        
        self.summarize_chain = summarize_prompt | self.chat_model

        chat_prompt = ChatPromptTemplate.from_messages([
            SystemMessagePromptTemplate.from_template(CHAT_SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="history"),
            HumanMessagePromptTemplate.from_template("{user_message}")
        ])
        
        self.chat_chain = chat_prompt | self.chat_model

    def chat(self, user_input: str) -> str:
        self.memory.chat_memory.add_user_message(user_input)

        conversation_history = "\n".join([
            f"User: {msg.text}" if msg.type == "user" else f"Assistant: {msg.text}"
            for msg in self.memory.chat_memory.messages
        ])
        print("Debug: Conversation History:")
        print(conversation_history)

        summary = self.summarize_chain.invoke({"conversation_history": conversation_history}).content.strip()

        print("Debug: Summary for RAG Query:")
        print(summary)

        rag_context = self.rag_system.retrieve(summary, similarity_top_k=5)

        print("Debug: Retrieved RAG Context:")
        print(rag_context)

        prompt_inputs = {
            "rag_context": rag_context,
            "history": self.memory.load_memory_variables({})["history"],
            "user_message": user_input,
        }

        response = self.chat_chain.invoke(prompt_inputs).content

        print("Debug: Assistant's Response:")
        print(response)

        self.memory.chat_memory.add_ai_message(response)

        return response


def main():
    chat_bot = RAGLangChainChat(
        data_dir=DEFAULT_DATA_DIR,
        persist_dir=DEFAULT_PERSIST_DIR,
        model_name="gpt-4o",
        temperature=0.0
    )

    print("Welcome to the RAG + LangChain chat demo. Type 'exit' to quit.\n")

    while True:
        user_input = input("User: ")
        if user_input.strip().lower() in ["exit", "quit"]:
            print("Exiting...")
            sys.exit(0)
        response = chat_bot.chat(user_input)
        print(f"Assistant: {response}\n")


if __name__ == "__main__":
    main()