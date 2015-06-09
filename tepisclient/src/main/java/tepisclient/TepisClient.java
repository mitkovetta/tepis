package tepisclient;

import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.client.Entity;
import javax.ws.rs.client.WebTarget;
import javax.ws.rs.core.Form;
import javax.ws.rs.core.GenericType;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.xml.bind.JAXBElement;

import tepisclient.ImageMetadata;
import tepisclient.AuthenticationFilter;

/**
 * Client for the tEPIS image management and storage (IMS) server. *
 * <p>
 * Provides read-only access to pixel data and metadata of digital slides stored
 * on the tEPIS IMS server.
 * 
 * @author Mitko Veta
 * 
 */

public class TepisClient {

	/*
	 * Main resource target.
	 */
	private WebTarget target;

	/*
	 * Image resource target derived from the main resource target.
	 */
	private WebTarget imageResource;

	/**
	 * 
	 * @param tepisUri
	 *            URI of the tEPIS image management and storage (IMS) server.
	 */
	public TepisClient(String tepisUri) {

		target = ClientBuilder.newClient().register(new AuthenticationFilter())
				.target(tepisUri);

		imageResource = target.path("ImageService").path("{image}")
				.path("{imageID}");

	}

	/**
	 * Authenticate on the tEPIS image management and storage (IMS) server.
	 * <p>
	 * Some resources can be accessed without authenticating on the server. If a
	 * resource that requires authentication is accessed without prior
	 * authentication, the server will generate an HTTP error and an appropriate
	 * exception will be thrown.
	 * 
	 * @param username
	 * @param password
	 */
	public void authenticate(String username, String password) {

		Form form = new Form();
		form.param("username", username);
		form.param("password", password);

		Response response = target
				.path("AccessService")
				.path("Login")
				.request(MediaType.APPLICATION_XML_TYPE)
				.post(Entity.entity(form,
						MediaType.APPLICATION_FORM_URLENCODED_TYPE));

		Integer status = response.readEntity(
				new GenericType<JAXBElement<Integer>>() {
				}).getValue();
		
		if (status != 1) {
			throw new RuntimeException("Authentication failed");
		}

	}

	/**
	 * Returns metadata of a digital slide.
	 * 
	 * @param imageID
	 *            ID of the digital slide for which the metadata is requested.
	 * @return
	 */
	public ImageMetadata getImageMetadata(String imageID) {

		return imageResource.path("metadata").resolveTemplate("image", "image")
				.resolveTemplate("imageID", imageID)
				.request(MediaType.APPLICATION_XML_TYPE)
				.get(ImageMetadata.class);

	}

	/**
	 * Returns pixel data of a rectangular region from a digital slide.
	 * <p>
	 * The returned pixel data is in the default image format and quality of the
	 * server.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the image region should be
	 *            read.
	 * @param irp
	 *            Parameter object specifying the rectangular image region.
	 * @return The requested image region.
	 * @see getImagePixelData(String imageID, ImageRegionParam irp,
	 *      ImageFormatParam ifp)
	 */
	public byte[] getImagePixelData(String imageID, ImageRegionParam irp) {

		return getImagePixelData(imageID, irp, null);
	}

	/**
	 * Returns pixel data of a rectangular region from a digital slide with
	 * specified image format and quality.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the image region should be
	 *            read.
	 * @param irp
	 *            Parameter object specifying the rectangular image region.
	 * @param ifp
	 *            Parameter object specifying the image format and quality of
	 *            the returned image data.
	 * @return The requested image region.
	 * @see getImagePixelData(String imageID, ImageRegionParam irp)
	 */
	public byte[] getImagePixelData(String imageID, ImageRegionParam irp,
			ImageFormatParam ifp) {

		WebTarget target = imageResource.path("pixeldata")
				.resolveTemplate("image", "image")
				.resolveTemplate("imageID", imageID);

		target = target.queryParam("x", irp.getX()).queryParam("y", irp.getY())
				.queryParam("width", irp.getWidth())
				.queryParam("height", irp.getHeight())
				.queryParam("level", irp.getLevel())
				.queryParam("unit", irp.getUnit());

		if (ifp != null) {
			target = target.queryParam("format", ifp.getFormat()).queryParam(
					"quality", ifp.getQuality());
		}

		return target.request(MediaType.APPLICATION_OCTET_STREAM_TYPE).get(
				byte[].class);

	}

	/**
	 * Returns pixel data of a tile from a digital slide.
	 * <p>
	 * The returned pixel data is in the default image format and quality of the
	 * server.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the image region should be
	 *            read.
	 * @param itp
	 *            Parameter object specifying the image tile.
	 * @return The requested image tile.
	 * @see getTiledImagePixelData(String imageID, ImageTileParam itp,
	 *      ImageFormatParam ifp)
	 */
	public byte[] getTiledImagePixelData(String imageID, ImageTileParam itp) {

		return getTiledImagePixelData(imageID, itp, null);
	}

	/**
	 * Returns pixel data of a tile from a digital slide with specified image
	 * format and quality.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the image region should be
	 *            read.
	 * @param itp
	 *            Parameter object specifying the image tile.
	 * @param ifp
	 *            Parameter object specifying the image format and quality of
	 *            the returned image data.
	 * @return The requested image tile.
	 * @see getTiledImagePixelData(String imageID, ImageTileParam itp)
	 */
	public byte[] getTiledImagePixelData(String imageID, ImageTileParam itp,
			ImageFormatParam ifp) {

		WebTarget target = imageResource.path("pixeldata")
				.resolveTemplate("image", "tiledimage")
				.resolveTemplate("imageID", imageID);

		target = target.queryParam("row", itp.getRow())
				.queryParam("col", itp.getCol())
				.queryParam("dir", itp.getDir());

		if (ifp != null) {
			target = target.queryParam("format", ifp.getFormat()).queryParam(
					"quality", ifp.getQuality());
		}

		return target.request(MediaType.APPLICATION_OCTET_STREAM_TYPE).get(
				byte[].class);

	}

	/**
	 * Returns pixel data of an image associated with a digital slide.
	 * <p>
	 * An associated image can be label, macro or thumbnail image.
	 * <p>
	 * The returned pixel data is in the default image format and quality of the
	 * server.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the associated should be
	 *            read.
	 * @param ait
	 *            Enumeration specifying the associated image type (label, macro
	 *            or thumbnail image).
	 * @return The requested associated image.
	 * @see getAssociatedImage(String imageID, AssociatedImageType ait,
	 *      ImageFormatParam ifp)
	 */
	public byte[] getAssociatedImage(String imageID, AssociatedImageType ait) {

		return getAssociatedImage(imageID, ait, null);

	}

	/**
	 * Returns pixel data of an image associated with a digital slide with
	 * specified image quality and format.
	 * <p>
	 * An associated image can be label, macro or thumbnail image.
	 * <p>
	 * The returned pixel data is in the default image format and quality of the
	 * server.
	 * 
	 * @param imageID
	 *            ID of the digital slide from which the associated should be
	 *            read.
	 * @param ait
	 *            Enumeration specifying the associated image type (label, macro
	 *            or thumbnail image).
	 * @param ifp
	 *            Parameter object specifying the image format and quality of
	 *            the returned image data.
	 * @return The requested associated image.
	 * @see getAssociatedImage(String imageID, AssociatedImageType ait)
	 */
	public byte[] getAssociatedImage(String imageID, AssociatedImageType ait,
			ImageFormatParam ifp) {

		WebTarget target = imageResource.path(ait.toString())
				.resolveTemplate("image", "image")
				.resolveTemplate("imageID", imageID);

		if (ifp != null) {
			target = target.queryParam("format", ifp.getFormat()).queryParam(
					"quality", ifp.getQuality());
		}

		return target.request(MediaType.APPLICATION_OCTET_STREAM_TYPE).get(
				byte[].class);

	}

}
