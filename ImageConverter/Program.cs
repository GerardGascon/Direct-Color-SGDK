//Dear the future person that reads this code,
//
//Please do not try to understand what the heck does this code mean,
//I do not understand it but it does the job.
//I just tried to translate a piece of code by Chilly Willy because it crashed on my PC.
//
//Thank you :)

using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;

namespace DirectColorBMP_CS {
	internal class Program {

		static ushort[] buffer = new ushort[198 * 240];

		static bool IsBMP_Valid(byte[] bmp){ 
			return (bmp[0] == 'B' && bmp[1] == 'M' && bmp[14] == 40) ? true : false;
		}

		static int BMP_Width(byte[] bmp) {
			return bmp[0x12] | (bmp[0x13] << 8) | (bmp[0x14] << 16) | (bmp[0x15] << 24);
		}

		static int BMP_Height(byte[] bmp) {
			return bmp[0x16] | (bmp[0x17] << 8) | (bmp[0x18] << 16) | (bmp[0x19] << 24);
		}

		static ushort blue(ushort color) {
			return (ushort)(((color & 0x001F) >> 1) & 0x000E);
		}

		static ushort green(ushort color) {
			return (ushort)(((color & 0x03E0) >> 6) & 0x000E);
		}

		static ushort red(ushort color) {
			return (ushort)(((color & 0x7C00) >> 11) & 0x000E);
		}

		static ushort swap(ushort val) {
			return (ushort)((val >> 8) | (val << 8));
		}

		static Bitmap ConvertTo16bpp(Image img) {
			var bmp = new Bitmap(img.Width, img.Height, PixelFormat.Format16bppRgb555);
			using (var gr = Graphics.FromImage(bmp))
				gr.DrawImage(img, new Rectangle(0, 0, img.Width, img.Height));
			return bmp;
		}

		static ImageCodecInfo GetEncoderInfo(String mimeType) {
			int j;
			ImageCodecInfo[] encoders;
			encoders = ImageCodecInfo.GetImageEncoders();
			for (j = 0; j < encoders.Length; ++j) {
				if (encoders[j].MimeType == mimeType)
					return encoders[j];
			}
			return null;
		}

		static int Main(string[] args) {
			if(args.Length == 0){
				Console.WriteLine("Please drag and drop the png onto the executable in order to convert the file.");
				Console.Read();
				return 1;
			}

			Bitmap _bmp = ConvertTo16bpp(Image.FromFile(args[0]));

			ImageCodecInfo codec = GetEncoderInfo("image/bmp");
			EncoderParameters encoder = new EncoderParameters(1);
			encoder.Param[0] = new EncoderParameter(Encoder.ColorDepth, 16);
			_bmp.Save(args[0].Replace(".png", ".bmp"), codec, encoder);

			string temp = args[0].Replace(".png", ".bmp");
			byte[] bmp = File.ReadAllBytes(temp);
			int y, w, h;
			ushort sc, dc;
			ushort[] p;

			if (IsBMP_Valid(bmp)) { 
				p = new ushort[bmp.Length + 0x36];
				Buffer.BlockCopy(bmp, 0, p, 0, bmp.Length);
				w = BMP_Width(bmp);
				h = BMP_Height(bmp);

				for (int j = 0; j < h; j++) {
					y = (h - 1) - j;
					for (int i = 0; i < w; i++) {
						sc = p[y * w + i];
						dc = (ushort)(blue(sc) << 8);
						dc |= (ushort)(green(sc) << 4);
						dc |= red(sc);
						buffer[j * w + i] = swap(dc);
					}
				}

				File.Delete(temp);
				temp = temp.Replace(".bmp", ".bin");

				byte[] result = new byte[192 * 224 * sizeof(ushort)];
				Buffer.BlockCopy(buffer, 0x36, result, 0, result.Length);

				File.WriteAllBytes(temp, result);
			}

			return 0;
		}
	}
}