package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Response.FileInfo;
import SocialNetwork.SocialNetwork.service.CloudinaryService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class CloudinaryController {
    private final CloudinaryService cloudinaryService;

    public CloudinaryController(CloudinaryService cloudinaryService) {
        this.cloudinaryService = cloudinaryService;
    }
    @PostMapping("/upload/image")
    public ResponseEntity<FileInfo> uploadImage(@RequestParam("file") MultipartFile files,
                                                @RequestParam("folder") String folderName) throws IOException {

        Map<String, Object> uploadResult = cloudinaryService.uploadFile(files, folderName);
        FileInfo fileInfo = new FileInfo();
        String publicId = (String) uploadResult.get("public_id");
        String fileName = publicId.split("/")[1];
        fileInfo.setName(fileName);
        fileInfo.setUrl(publicId);

        return ResponseEntity.ok().body(fileInfo);
    }
    @PostMapping("/upload/images")
    public ResponseEntity<List<FileInfo>> uploadImages(@RequestParam("file") MultipartFile[] files,
                                                       @RequestParam("folder") String folderName) throws IOException {

        List<FileInfo> fileInfoList = new ArrayList<>();

        for (MultipartFile file : files) {
            Map<String, Object> uploadResult = cloudinaryService.uploadFile(file, folderName);

            FileInfo fileInfo = new FileInfo();

            String publicId = (String) uploadResult.get("public_id");
            String fileName = publicId.split("/")[1];


            fileInfo.setName(fileName);
            fileInfo.setUrl(publicId);

            fileInfoList.add(fileInfo);
        }


        return ResponseEntity.ok(fileInfoList);
    }



}