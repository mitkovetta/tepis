package tepisclient;

/**
 * Contains parameters specifying a rectangular region from a digital slide.
 * 
 * @author Mitko Veta
 * 
 */

public class ImageRegionParam {

	/*
	 * Top-left corner of the rectangular region specified by the horizontal (x)
	 * and vertical (y) coordinate, and width and height.
	 */
	private final Float x;
	private final Float y;
	private final Float width;
	private final Float height;

	/*
	 * Level of the rectangular region.
	 */
	private final Integer level;

	/*
	 * Unit of the coordinates of the rectangular region.
	 */
	private final Unit unit;

	/**
	 * When using a parameter object constructed with this constructor, the
	 * level and unit will not be specified with the server request. The default
	 * values will be assumed by the server.
	 * 
	 * @param x
	 *            Horizontal coordinate of the top-left corner of the
	 *            rectangular region.
	 * @param y
	 *            Vertical coordinate of the top-left corner of the rectangular
	 *            region.
	 * @param width
	 *            Width of the rectangular region.
	 * @param height
	 *            Height of the rectangular region.
	 */
	public ImageRegionParam(Float x, Float y, Float width, Float height) {

		this(x, y, width, height, null, null);
	}

	/**
	 * 
	 * When using a parameter object constructed with this constructor, the unit
	 * will not be specified with the server request. The default value will be
	 * assumed by the server.
	 * 
	 * @param x
	 *            Horizontal coordinate of the top-left corner of the
	 *            rectangular region.
	 * @param y
	 *            Vertical coordinate of the top-left corner of the rectangular
	 *            region.
	 * @param width
	 *            Width of the rectangular region.
	 * @param height
	 *            Height of the rectangular region.
	 * @param level
	 *            Level of the rectangular region.
	 */
	public ImageRegionParam(Float x, Float y, Float width, Float height,
			Integer level) {

		this(x, y, width, height, level, null);
	}

	/**
	 * @param x
	 *            Horizontal coordinate of the top-left corner of the
	 *            rectangular region.
	 * @param y
	 *            Vertical coordinate of the top-left corner of the rectangular
	 *            region.
	 * @param width
	 *            Width of the rectangular region.
	 * @param height
	 *            Height of the rectangular region.
	 * @param level
	 *            Level of the rectangular region.
	 * @param unit
	 *            Unit of the coordinates of the rectangular region.
	 */
	public ImageRegionParam(Float x, Float y, Float width, Float height,
			Integer level, Unit unit) {

		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.level = level;
		this.unit = unit;
	}

	/**
	 * Returns parameters for a region located below the current one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam nextCol() {

		Float x = this.x + this.width;

		return new ImageRegionParam(x, this.y, this.width, this.height,
				this.level, this.unit);
	}

	/**
	 * Returns parameters for a region located to the right from the current
	 * one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam nextRow() {

		Float y = this.y + this.height;

		return new ImageRegionParam(this.x, y, this.width, this.height,
				this.level, this.unit);
	}

	/**
	 * Returns parameters for a region with the same size and position located
	 * one level up from the current one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam nextLevel() {

		Integer level = this.level + 1;

		return new ImageRegionParam(this.x, this.y, this.width, this.height,
				level, this.unit);
	}

	/**
	 * Returns parameters for a region located above the current one from the
	 * current one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam prevCol() {

		Float x = this.x - this.width;

		return new ImageRegionParam(x, this.y, this.width, this.height,
				this.level, this.unit);
	}

	/**
	 * Returns parameters for a region located to the left from the current one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam prevRow() {

		Float y = this.y - this.height;

		return new ImageRegionParam(this.x, y, this.width, this.height,
				this.level, this.unit);
	}

	/**
	 * Returns parameters for a region with the same size and position located
	 * one level below from the current one.
	 * 
	 * @return Parameters for the new region.
	 */
	public ImageRegionParam prevLevel() {

		Integer level = this.level - 1;

		return new ImageRegionParam(this.x, this.y, this.width, this.height,
				level, this.unit);
	}

	/**
	 * Gets the horizontal coordinate of the rectangular region.
	 * 
	 * @return The horizontal coordinate.
	 */
	public Float getX() {

		return x;
	}

	/**
	 * Gets the vertical coordinate of the rectangular region.
	 * 
	 * @return The vertical coordinate.
	 */
	public Float getY() {

		return y;
	}

	/**
	 * Gets the width of the rectangular region.
	 * 
	 * @return The width.
	 */
	public Float getWidth() {

		return width;
	}

	/**
	 * Gets the height of the rectangular region.
	 * 
	 * @return The height.
	 */
	public Float getHeight() {

		return height;
	}

	/**
	 * Gets the level of the rectangular region.
	 * 
	 * @return The level.
	 */
	public Integer getLevel() {

		return level;
	}

	/**
	 * Gets the unit of the coordinates of the rectangular region.
	 * 
	 * @return The unit.
	 */
	public Unit getUnit() {

		return unit;
	}

	@Override
	public String toString() {
		return "ImageRegionParam [x=" + x + ", y=" + y + ", width=" + width
				+ ", height=" + height + ", level=" + level + ", unit=" + unit
				+ "]";
	}

}