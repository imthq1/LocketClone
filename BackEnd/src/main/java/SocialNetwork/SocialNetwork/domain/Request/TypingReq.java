package SocialNetwork.SocialNetwork.domain.Request;

import lombok.Data;

@Data
public  class TypingReq {
    private boolean typing;
    @Data
    public static class TypingEvent {
        private Long conversationId;
        private Long userId;
        private boolean typing;
        public TypingEvent(Long conversationId, Long userId, boolean typing) {
            this.conversationId = conversationId;
            this.userId = userId;
            this.typing = typing;
        }
    }

}