# File: rag_system.py

import os
from llama_index.core import (
    SimpleDirectoryReader,
    VectorStoreIndex,
    StorageContext,
    load_index_from_storage,
)
from llama_index.llms.openai import OpenAI

class RAGSystem:
    """
    A Retrieval Augmented Generation (RAG) system that loads or builds
    a vector index from documents and provides a query interface via retrieval.

    When an instance is created, it accepts:
      - data_dir: directory path containing the data documents (e.g., txt, pdf)
      - persist_dir: directory path where the vector index is (or will be) persisted

    If a persisted index is found in persist_dir, it is loaded.
    Otherwise, documents from data_dir are read, an index is built, and then persisted.
    """

    def __init__(self, data_dir: str, persist_dir: str):
        """
        Initialize the RAG system.

        Args:
            data_dir (str): Directory path with your data documents.
            persist_dir (str): Directory path to store/load the persisted vector index.
        """
        self.data_dir = data_dir
        self.persist_dir = persist_dir

        # Check if the persistence directory exists and contains files.
        if os.path.exists(self.persist_dir) and os.listdir(self.persist_dir):
            # Persisted index exists: load it from the storage.
            storage_context = StorageContext.from_defaults(persist_dir=self.persist_dir)
            self.index = load_index_from_storage(storage_context)
            print(f"Loaded persisted index from '{self.persist_dir}'.")
        else:
            # No persisted index found: load documents and build the index.
            print(f"No persisted index found at '{self.persist_dir}'.")
            print(f"Loading data from '{self.data_dir}' and building the vector index...")
            docs = SimpleDirectoryReader(input_dir=self.data_dir, recursive=True).load_data()
            # Build the vector index (the progress bar will be shown if enabled).
            self.index = VectorStoreIndex.from_documents(docs, show_progress=True)
            # Persist the index for future use.
            self.index.storage_context.persist(persist_dir=self.persist_dir)
            print(f"Index built and persisted to '{self.persist_dir}'.")

    def retrieve(self, query: str, similarity_top_k: int = 5) -> str:
        """
        Retrieve data based on the input query using the retriever.

        Args:
            query (str): The query string.
            similarity_top_k (int): Number of top similar document segments to retrieve (default is 5).

        Returns:
            str: A formatted string containing the scores and content of retrieved document nodes.
        """
        # Create a retriever from the index using as_retriever instead of as_query_engine.
        retriever = self.index.as_retriever(similarity_top_k=similarity_top_k)
        # Retrieve the document nodes that best match the query.
        source_nodes = retriever.retrieve(query)
        
        # Format the output from the retrieved nodes.
        results = []
        for node in source_nodes:
            results.append(
                f"---------------------------------------------\n"
                f"Score: {node.score:.3f}\n"
                f"{node.get_content()}\n"
                f"---------------------------------------------"
            )
        return "\n\n".join(results)

# Example usage:
if __name__ == "__main__":
    # Set the data directory (documents) and the persistence directory.
    DATA_DIR = "edu_docs"         # Change this path if your documents are elsewhere.
    PERSIST_DIR = "vector_k11"  # This directory stores the persisted vector index.

    # Instantiate the RAG system.
    rag_system = RAGSystem(data_dir=DATA_DIR, persist_dir=PERSIST_DIR)

    # Example: Query the system.
    query_text = "什么是光合作用？"
    result = rag_system.retrieve(query_text, similarity_top_k=10)
    print("Retrieved Response:")
    print(result)