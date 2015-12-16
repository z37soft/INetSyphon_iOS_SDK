#pragma	once

//#define	OSC_PORT			(50477)

#define RD_TCPVisualTransfer_PixelType_JPEG         (0)
#define RD_TCPVisualTransfer_PixelType_JPEGGLITCH   (1)
#define RD_TCPVisualTransfer_PixelType_RAW          (2)
#define RD_TCPVisualTransfer_PixelType_PNG          (3)
#define RD_TCPVisualTransfer_PixelType_TURBOJPEG    (4)
#define RD_TCPVisualTransfer_PixelType_DXT1         (5)

#define	RD_TCPVisualTransfer_RDP_PROTOCOL_PIXELSTREAM_ID        (1)
#define RD_TCPVisualTransfer_HeaderSize                         (sizeof(unsigned int)*4)

#define	RD_TCPVisualTransferRequestToCloseSessionNotification			@"RD_TCPVisualTransferRequestToCloseSessionNotification"
