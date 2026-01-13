-- Enable pgvector extension for vector similarity search
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable other useful extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";      -- Fuzzy text search
CREATE EXTENSION IF NOT EXISTS "btree_gin";    -- GIN index support
CREATE EXTENSION IF NOT EXISTS "btree_gist";   -- GIST index support

-- Example: Create embeddings table for AI workloads
CREATE TABLE IF NOT EXISTS embeddings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    embedding vector(1536),  -- OpenAI ada-002 dimension
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for vector similarity search (cosine distance)
CREATE INDEX IF NOT EXISTS embeddings_embedding_idx
ON embeddings USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Create index for metadata queries
CREATE INDEX IF NOT EXISTS embeddings_metadata_idx
ON embeddings USING GIN (metadata);

-- Example function for similarity search
CREATE OR REPLACE FUNCTION search_similar(
    query_embedding vector(1536),
    match_count INT DEFAULT 10,
    match_threshold FLOAT DEFAULT 0.8
)
RETURNS TABLE (
    id UUID,
    content TEXT,
    metadata JSONB,
    similarity FLOAT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        e.id,
        e.content,
        e.metadata,
        1 - (e.embedding <=> query_embedding) AS similarity
    FROM embeddings e
    WHERE 1 - (e.embedding <=> query_embedding) > match_threshold
    ORDER BY e.embedding <=> query_embedding
    LIMIT match_count;
END;
$$;
