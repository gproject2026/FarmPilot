import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';

import { CloudinaryService } from './cloudinary.service';

@Controller('uploads')
export class UploadsController {
  constructor(
    private readonly cloudinaryService:
      CloudinaryService,
  ) {}

  @Post('image')
  @UseInterceptors(
    FileInterceptor('image', {
      storage: memoryStorage(),

      fileFilter: (
        request,
        file,
        callback,
      ) => {
        const allowedTypes = [
          'image/jpeg',
          'image/jpg',
          'image/png',
          'image/webp',
        ];

        if (
          !allowedTypes.includes(
            file.mimetype,
          )
        ) {
          callback(
            new BadRequestException(
              'Only JPG, JPEG, PNG, and WEBP images are allowed',
            ),
            false,
          );

          return;
        }

        callback(null, true);
      },

      limits: {
        fileSize: 5 * 1024 * 1024,
      },
    }),
  )
  async uploadImage(
    @UploadedFile()
    file: Express.Multer.File,
  ) {
    if (!file) {
      throw new BadRequestException(
        'Image file is required',
      );
    }

    const result =
      await this.cloudinaryService.uploadImage(
        file,
        'farmpilot/uploads',
      );

    return {
      message:
        'Image uploaded successfully',
      filename: result.public_id,
      imageUrl: result.secure_url,
      publicId: result.public_id,
    };
  }
}