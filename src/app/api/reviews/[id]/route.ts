import { prisma } from '@/lib/prisma';
import { auth } from '@/auth';
import { NextResponse } from 'next/server';
import { updateSpaceAvgRating } from '@/lib/reviewUtils';

// Handles DELETE requests to /api/reviews/[id]
// Deletes a review
export async function DELETE(request: Request, { params }: { params: { id: string } }) {
    try {
        // Check if user is authenticated
        const session = await auth();

        if (!session || !session.user) {
            return NextResponse.json({ error: "User not authenticated" }, { status: 401 });
        }

        if (session.user.role !== 'CLIENT') {
            return NextResponse.json({ error: "User not authorized" }, { status: 403 });
        }
        
        const { id } = params;

        // Convert the ID to a number
        const reviewId = parseInt(params.id);

        if (isNaN(reviewId)) {
            return NextResponse.json(
                { error: 'Invalid ID' },
                { status: 400 }
            );
        }

        // Verify that the review exists and belongs to the user
        const review = await prisma.review.findUnique({
            where: { id: reviewId },
            select: { userId: true, spaceId: true }
        });

        if (!review) {
            return NextResponse.json({ error: 'Review not found' }, { status: 404 });
        }

        if (review.userId !== session.user.id) {
            return NextResponse.json({ error: 'Not authorized to delete this review' }, { status: 403 });
        }

        // Delete the review
        await prisma.review.delete({
            where: { id: reviewId },
        });

        // Update the average rating of the associated collectionPoint
        await updateSpaceAvgRating(review.spaceId);

        return new NextResponse(null, { status: 204 });
    } catch (error) {
        return NextResponse.json({ error: 'Failed to delete review' }, { status: 500 });
    }
}