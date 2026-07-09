import { Injectable } from '@nestjs/common';
import { unlink } from 'fs/promises';
import { join } from 'path';

@Injectable()
export class UploadsService {
  async removeImage(imageUrl: string) {
    try {
      const fileName = imageUrl.split('/').pop();

      if (!fileName) {
        return {
          message: 'Invalid image URL',
        };
      }

      const filePath = join(
        process.cwd(),
        'uploads',
        fileName,
      );

      await unlink(filePath);

      return {
        message: 'Image deleted successfully',
      };
    } catch (error) {
      return {
        message: 'Image not found or already deleted',
      };
    }
  }
}