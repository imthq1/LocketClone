package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.FriendRequest;
import SocialNetwork.SocialNetwork.domain.Request.FriendRequestItemDTO;
import SocialNetwork.SocialNetwork.domain.Response.FriendRequestBySender;
import SocialNetwork.SocialNetwork.service.FriendService;
import SocialNetwork.SocialNetwork.service.UserService;
import SocialNetwork.SocialNetwork.util.ApiMessage;

import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import SocialNetwork.SocialNetwork.util.error.IdInValidException;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.io.ByteArrayOutputStream;
import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.Map;

@RequestMapping("/api/v1")
@RestController
public class FriendController {
    private final UserService userService;
    private final FriendService friendService;
    private final SecurityUtil securityUtil;
    public FriendController(UserService userService, FriendService friendService,
                            SecurityUtil securityUtil) {
        this.userService = userService;
        this.friendService = friendService;
        this.securityUtil = securityUtil;
    }
    @PostMapping("/sendFriendByQrCode/{token}")
    @ApiMessage("send ")
    public ResponseEntity<Void> sendFriendByQrCode(@PathVariable String token)
    throws Exception{
        String email = SecurityUtil.getCurrentUserLogin().get();
        this.friendService.sendRequestByQr(email,token);
        return ResponseEntity.ok().build();
    }
    @GetMapping("/qr/my")
    public ResponseEntity<Map<String, String>> myInviteQr() throws Exception {
        String email = SecurityUtil.getCurrentUserLogin()
                .orElseThrow(() -> new IllegalStateException("User not logged in"));
        long myId = userService.getUserByEmail(email).getId();

        String token = this.securityUtil.createTokenforQR(myId,email);
        String deeplink = "myapp://invite?id=" +token;
        String https = "https://example.com/invite?id=" + token;

        BitMatrix m = new MultiFormatWriter().encode(deeplink, BarcodeFormat.QR_CODE, 720, 720);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(m, "PNG", out);
        String base64 = Base64.getEncoder().encodeToString(out.toByteArray());

        Map<String, String> resp = Map.of(
                "deeplink", deeplink,
                "https", https,
                "qrBase64", "data:image/png;base64," + base64
        );
        return ResponseEntity.ok(resp);
    }
    @PostMapping("/sendFriendRq/{idAddressee}")
    @ApiMessage("Add friend")
    public ResponseEntity<Void> sendFriendRq(@PathVariable long idAddressee) throws IdInValidException {
        String email = SecurityUtil.getCurrentUserLogin().get();
        if(this.friendService.existByAdresseeIdAndSender(idAddressee,email))
        {
            throw new IdInValidException("Friend Request was exist");
        }
        this.friendService.sendRequestFr(email, idAddressee);
        return ResponseEntity.ok().build();
    }
    @GetMapping("/listRequestByAddressee")
    @ApiMessage("List request add friend to me")
    public ResponseEntity<List<FriendRequestItemDTO>> listRequestByAddressee() {
        List<FriendRequestItemDTO> data = friendService.listReceivedRequestsForCurrentUser();
        return ResponseEntity.ok(data);
    }
    @GetMapping("/listFriendSend")
    @ApiMessage("Get list friend sended")
    public ResponseEntity<Page<FriendRequestBySender>> listFriendSend(Pageable pageable) {
        String email = SecurityUtil.getCurrentUserLogin().get();
        return ResponseEntity.ok(this.friendService.listFriendBySender(email, friendStatus.pending,pageable));
    }


}
