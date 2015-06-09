package tepisclient;

/**
 * Contains parameters specifying the image format and quality.
 * 
 * @author Mitko Veta
 * 
 */

public class ImageFormatParam {

	/*
	 * Image format.
	 */
	private final Format format;

	/*
	 * Image quality.
	 * <p>
	 * Must be an integer between 1 and 100.
	 */
	private final Integer quality;

	/**
	 * @param format
	 */
	public ImageFormatParam(Format format) {

		this(format, null);
	}

	/**
	 * @param format
	 * @param quality
	 */
	public ImageFormatParam(Format format, Integer quality) {

		this.format = format;
		this.quality = quality;
	}

	/**
	 * Gets the value of the format property.
	 * 
	 * @return
	 */
	public Format getFormat() {

		return format;
	}

	/**
	 * Gets the value of the quality property.
	 * 
	 * @return
	 */
	public Integer getQuality() {

		return quality;
	}

	@Override
	public String toString() {

		return "ImageFormatParam [format=" + format + ", quality=" + quality
				+ "]";
	}

}
