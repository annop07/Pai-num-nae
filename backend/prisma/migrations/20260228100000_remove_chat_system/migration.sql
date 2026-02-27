-- DropTable (Message references ChatRoom, so drop first)
DROP TABLE IF EXISTS "Message";

-- DropTable
DROP TABLE IF EXISTS "ChatRoom";

-- DropEnum
DROP TYPE IF EXISTS "ChatStatus";

-- DropEnum
DROP TYPE IF EXISTS "MessageType";
