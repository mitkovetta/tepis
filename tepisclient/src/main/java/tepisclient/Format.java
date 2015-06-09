package tepisclient;

/**
 * Enumeration for image formats.
 * 
 * @author Mitko Veta
 *
 */

public enum Format {
	
	JPEG("image/jpeg", "jpg"),
	PNG("image/png", "png");
	
	private String format;
	private String fileExtension;
	
	private Format(String format, String fileExtension) {
		
		this.format = format;
		this.fileExtension = fileExtension;		
	}

	@Override
	public String toString() {
		
		return format;
	}
	
	/**
	 * Returns the file extension for the image type.
	 * 
	 * @return
	 */
	public String getFileExtension() {
		return fileExtension;
	}

}
